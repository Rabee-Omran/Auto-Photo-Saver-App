#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

/**
 * FlutterWindow constructor initializes network monitoring state
 */
FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project), stop_network_monitor_(false) {}

FlutterWindow::~FlutterWindow() {
  StopNetworkMonitoring();
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Set up network connectivity channels
  SetupNetworkChannels();

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  StopNetworkMonitoring();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

/**
 * Set up Flutter method and event channels for network connectivity
 * Handles network type queries and real-time network change notifications
 */
void FlutterWindow::SetupNetworkChannels() {
  if (!flutter_controller_ || !flutter_controller_->engine()) {
    return;
  }

  // Set up method channel for network type queries
  network_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "com.rabee.omran.network",
      &flutter::StandardMethodCodec::GetInstance());

  network_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "getNetworkType") {
          result->Success(flutter::EncodableValue(GetNetworkType()));
        } else {
          result->NotImplemented();
        }
      });

  // Set up event channel for network change notifications
  network_event_channel_ = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "com.rabee.omran.network/events",
      &flutter::StandardEventCodec<flutter::EncodableValue>::GetInstance());

  network_event_channel_->SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [this](const flutter::EncodableValue* arguments,
                 std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
            network_event_sink_ = std::move(events);
            StartNetworkMonitoring();
            // Send initial network state
            if (network_event_sink_) {
              network_event_sink_->Success(flutter::EncodableValue(GetNetworkType()));
            }
            return nullptr;
          },
          [this](const flutter::EncodableValue* arguments) {
            StopNetworkMonitoring();
            network_event_sink_.reset();
            return nullptr;
          }));

  // Start network monitoring
  StartNetworkMonitoring();
}

/**
 * Get current network connection type using Windows Internet API
 * Detects ethernet, mobile, wifi, or offline status
 */
std::string FlutterWindow::GetNetworkType() {
  // Check internet connectivity using WinInet
  DWORD flags;
  if (!InternetGetConnectedState(&flags, 0)) {
    return "offline";
  }

  // Check for specific connection types based on flags
  if (flags & INTERNET_CONNECTION_LAN) {
    return "ethernet";
  } else if (flags & INTERNET_CONNECTION_MODEM) {
    return "mobile";
  } else if (flags & INTERNET_CONNECTION_PROXY) {
    // Proxy usually means some form of network connection
    return "wifi";
  } else {
    // Default to wifi if we have internet but can't determine specific type
    return "wifi";
  }
}

/**
 * Start background network monitoring thread
 */
void FlutterWindow::StartNetworkMonitoring() {
  if (network_monitor_thread_.joinable()) {
    return; // Already monitoring
  }
  
  stop_network_monitor_ = false;
  network_monitor_thread_ = std::thread(&FlutterWindow::NetworkMonitorLoop, this);
}

/**
 * Stop network monitoring and clean up thread
 */
void FlutterWindow::StopNetworkMonitoring() {
  stop_network_monitor_ = true;
  if (network_monitor_thread_.joinable()) {
    network_monitor_thread_.join();
  }
}

/**
 * Background network monitoring loop
 * Continuously checks network status and emits events on changes
 */
void FlutterWindow::NetworkMonitorLoop() {
  std::string last_network_type = GetNetworkType();
  
  while (!stop_network_monitor_) {
    std::this_thread::sleep_for(std::chrono::seconds(2));
    
    if (stop_network_monitor_) break;
    
    std::string current_network_type = GetNetworkType();
    if (current_network_type != last_network_type) {
      last_network_type = current_network_type;
      
      // Post network change event to main thread
      if (flutter_controller_ && flutter_controller_->engine()) {
        flutter_controller_->engine()->PostTaskOnUIThread([this, current_network_type]() {
          if (network_event_sink_) {
            network_event_sink_->Success(flutter::EncodableValue(current_network_type));
          }
        });
      }
    }
  }
}
