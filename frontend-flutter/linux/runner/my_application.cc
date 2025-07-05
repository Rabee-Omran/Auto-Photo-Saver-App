#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <ifaddrs.h>
#include <netdb.h>

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  NetworkDetection* network_detection;  // Network detection instance
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

/**
 * Get current network connection type by examining network interfaces
 * Detects wifi, ethernet, mobile, or offline status
 */
static std::string get_network_type() {
  struct ifaddrs *ifaddr, *ifa;
  std::string network_type = "offline";
  
  if (getifaddrs(&ifaddr) == -1) {
    return network_type;
  }
  
  // Iterate through network interfaces
  for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
    if (ifa->ifa_addr == NULL) continue;
    
    int family = ifa->ifa_addr->sa_family;
    if (family == AF_INET || family == AF_INET6) {
      if (strcmp(ifa->ifa_name, "lo") != 0) { // Skip loopback interface
        // Detect interface type by name patterns
        if (strncmp(ifa->ifa_name, "wlan", 4) == 0 || 
            strncmp(ifa->ifa_name, "wifi", 4) == 0) {
          network_type = "wifi";
          break;
        } else if (strncmp(ifa->ifa_name, "eth", 3) == 0 || 
                   strncmp(ifa->ifa_name, "en", 2) == 0) {
          network_type = "ethernet";
          break;
        } else if (strncmp(ifa->ifa_name, "wwan", 4) == 0 || 
                   strncmp(ifa->ifa_name, "usb", 3) == 0) {
          network_type = "mobile";
          break;
        } else {
          // Default to wifi if we can't determine specific type
          network_type = "wifi";
        }
      }
    }
  }
  
  freeifaddrs(ifaddr);
  return network_type;
}

/**
 * Background network monitoring loop
 * Continuously checks network status and emits events on changes
 */
static void network_monitor_loop(NetworkDetection* network_detection) {
  std::string last_network_type = get_network_type();
  network_detection->current_network_type = last_network_type;
  
  while (!network_detection->stop_monitor) {
    std::this_thread::sleep_for(std::chrono::seconds(2));
    
    if (network_detection->stop_monitor) break;
    
    std::string current_network_type = get_network_type();
    if (current_network_type != last_network_type) {
      last_network_type = current_network_type;
      network_detection->current_network_type = current_network_type;
      
      // Emit network change event on main thread
      g_idle_add([](gpointer user_data) -> gboolean {
        NetworkDetection* nd = static_cast<NetworkDetection*>(user_data);
        if (nd->event_sink) {
          fl_event_sink_send(nd->event_sink, 
                           fl_value_new_string(nd->current_network_type.c_str()),
                           nullptr, nullptr);
        }
        return G_SOURCE_REMOVE;
      }, network_detection);
    }
  }
}

/**
 * Set up Flutter method and event channels for network connectivity
 * Handles network type queries and real-time network change notifications
 */
static void setup_network_channels(MyApplication* self, FlView* view) {
  FlEngine* engine = fl_view_get_engine(view);
  if (!engine) return;
  
  FlBinaryMessenger* messenger = fl_engine_get_binary_messenger(engine);
  
  // Set up method channel for network type queries
  self->network_detection->method_channel = fl_method_channel_new(
      messenger, "com.rabee.omran.network",
      FL_METHOD_CODEC(fl_standard_method_codec_new()));
  
  fl_method_channel_set_method_call_handler(
      self->network_detection->method_channel,
      [](FlMethodCall* method_call, FlMethodResult* result, gpointer user_data) {
        MyApplication* app = static_cast<MyApplication*>(user_data);
        const gchar* method = fl_method_call_get_name(method_call);
        
        if (strcmp(method, "getNetworkType") == 0) {
          std::string network_type = get_network_type();
          fl_method_result_return_value(result, 
                                       fl_value_new_string(network_type.c_str()));
        } else {
          fl_method_result_return_not_implemented(result);
        }
      }, self, nullptr);
  
  // Set up event channel for network change notifications
  self->network_detection->event_channel = fl_event_channel_new(
      messenger, "com.rabee.omran.network/events",
      FL_METHOD_CODEC(fl_standard_method_codec_new()));
  
  fl_event_channel_set_stream_handler(
      self->network_detection->event_channel,
      [](FlEventChannel* channel, FlMethodCall* method_call, 
         FlEventSink* event_sink, gpointer user_data) -> FlMethodResult* {
        MyApplication* app = static_cast<MyApplication*>(user_data);
        
        const gchar* method = fl_method_call_get_name(method_call);
        if (strcmp(method, "listen") == 0) {
          // Store event sink and start monitoring
          app->network_detection->event_sink = event_sink;
          app->network_detection->stop_monitor = false;
          app->network_detection->monitor_thread = 
              std::thread(network_monitor_loop, app->network_detection);
          
          // Send initial network state
          std::string network_type = get_network_type();
          fl_event_sink_send(event_sink, 
                            fl_value_new_string(network_type.c_str()),
                            nullptr, nullptr);
          
          return fl_method_result_new_success(nullptr);
        } else if (strcmp(method, "cancel") == 0) {
          // Stop monitoring and clean up
          app->network_detection->stop_monitor = true;
          if (app->network_detection->monitor_thread.joinable()) {
            app->network_detection->monitor_thread.join();
          }
          app->network_detection->event_sink = nullptr;
          return fl_method_result_new_success(nullptr);
        }
        
        return fl_method_result_new_not_implemented();
      },
      [](FlEventChannel* channel, FlMethodCall* method_call, 
         gpointer user_data) -> FlMethodResult* {
        MyApplication* app = static_cast<MyApplication*>(user_data);
        // Clean up when stream is cancelled
        app->network_detection->stop_monitor = true;
        if (app->network_detection->monitor_thread.joinable()) {
          app->network_detection->monitor_thread.join();
        }
        app->network_detection->event_sink = nullptr;
        return fl_method_result_new_success(nullptr);
      }, self);
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "auto_photo_saver_app");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "auto_photo_saver_app");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  // Setup network detection channels
  setup_network_channels(self, view);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  // Initialize network detection
  self->network_detection = g_new0(NetworkDetection, 1);
  self->network_detection->stop_monitor = false;

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  // Stop network monitoring
  if (self->network_detection) {
    self->network_detection->stop_monitor = true;
    if (self->network_detection->monitor_thread.joinable()) {
      self->network_detection->monitor_thread.join();
    }
    g_free(self->network_detection);
    self->network_detection = nullptr;
  }

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
