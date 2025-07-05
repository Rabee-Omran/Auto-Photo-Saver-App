#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#include <gtk/gtk.h>
#include <flutter_linux/flutter_linux.h>
#include <glib.h>
#include <gio/gio.h>
#include <string>
#include <memory>
#include <thread>
#include <atomic>

G_DECLARE_FINAL_TYPE(MyApplication, my_application, MY, APPLICATION,
                     GtkApplication)

/**
 * my_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* my_application_new();

/**
 * NetworkDetection structure for managing network connectivity monitoring
 * Handles network interface detection and Flutter channel communication
 */
typedef struct {
  GNetworkMonitor* monitor;           // GNetworkMonitor for connectivity detection
  FlMethodChannel* method_channel;    // Method channel for network type queries
  FlEventChannel* event_channel;      // Event channel for network change notifications
  FlEventSink* event_sink;            // Event sink for sending network updates
  std::thread monitor_thread;         // Background thread for network monitoring
  std::atomic<bool> stop_monitor;     // Atomic flag to stop monitoring thread
  std::string current_network_type;   // Current detected network type
} NetworkDetection;

#endif  // FLUTTER_MY_APPLICATION_H_
