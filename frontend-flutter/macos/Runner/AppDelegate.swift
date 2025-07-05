import Cocoa
import FlutterMacOS
import Network

/**
 * macOS AppDelegate handles network connectivity monitoring
 * Provides Flutter method channels for network status on macOS
 */
@main
class AppDelegate: FlutterAppDelegate {
  // Network monitoring properties
  var networkMonitor: NWPathMonitor?
  var networkEventSink: FlutterEventSink?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    setupNetworkChannels(controller: controller)
    super.applicationDidFinishLaunching(notification)
  }
  
  /**
   * Set up network connectivity channels for Flutter communication
   */
  private func setupNetworkChannels(controller: FlutterViewController) {
    // Initialize network method and event channels
    let networkChannel = FlutterMethodChannel(name: "com.rabee.omran.network", binaryMessenger: controller.engine.binaryMessenger)
    let networkEventChannel = FlutterEventChannel(name: "com.rabee.omran.network/events", binaryMessenger: controller.engine.binaryMessenger)
    
    // Create network path monitor for connectivity detection
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")
    self.networkMonitor = monitor
    
    // Handle network type requests from Flutter
    networkChannel.setMethodCallHandler { (call, result) in
      if call.method == "getNetworkType" {
        let type = self.getNetworkType(monitor: monitor)
        result(type)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Set up real-time network event streaming
    networkEventChannel.setStreamHandler(NetworkStreamHandler(monitor: monitor, queue: queue))
    monitor.start(queue: queue)
  }
  
  /**
   * Get current network connection type (wifi, ethernet, mobile, or offline)
   */
  private func getNetworkType(monitor: NWPathMonitor) -> String {
    let path = monitor.currentPath
    if path.usesInterfaceType(.wifi) {
      return "wifi"
    } else if path.usesInterfaceType(.wiredEthernet) {
      return "ethernet"
    } else if path.usesInterfaceType(.cellular) {
      return "mobile"
    } else {
      return "offline"
    }
  }
}

/**
 * NetworkStreamHandler manages real-time network connectivity updates on macOS
 * Provides event stream for network status changes
 */
class NetworkStreamHandler: NSObject, FlutterStreamHandler {
  let monitor: NWPathMonitor
  let queue: DispatchQueue
  var eventSink: FlutterEventSink?
  
  init(monitor: NWPathMonitor, queue: DispatchQueue) {
    self.monitor = monitor
    self.queue = queue
    super.init()
  }
  
  /**
   * Start listening for network changes and emit events to Flutter
   */
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    // Set up path update handler for network changes
    monitor.pathUpdateHandler = { path in
      let type: String
      if path.usesInterfaceType(.wifi) {
        type = "wifi"
      } else if path.usesInterfaceType(.wiredEthernet) {
        type = "ethernet"
      } else if path.usesInterfaceType(.cellular) {
        type = "mobile"
      } else {
        type = "offline"
      }
      // Ensure events are sent on main thread
      DispatchQueue.main.async {
        events(type)
      }
    }
    return nil
  }
  
  /**
   * Stop listening for network changes and clean up resources
   */
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    monitor.cancel()
    return nil
  }
}