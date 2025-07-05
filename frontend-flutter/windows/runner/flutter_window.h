#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/standard_event_codec.h>
#include <windows.h>
#include <wininet.h>
#include <iphlpapi.h>
#include <vector>
#include <string>
#include <memory>
#include <thread>
#include <atomic>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
  
  // Network detection
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> network_channel_;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> network_event_channel_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> network_event_sink_;
  std::thread network_monitor_thread_;
  std::atomic<bool> stop_network_monitor_;
  
  // Network detection methods
  void SetupNetworkChannels();
  std::string GetNetworkType();
  void StartNetworkMonitoring();
  void StopNetworkMonitoring();
  void NetworkMonitorLoop();
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
