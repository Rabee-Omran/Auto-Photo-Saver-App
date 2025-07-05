import Flutter
import UIKit
import Network
import Photos

/**
 * AppDelegate handles network connectivity monitoring and image saving to gallery
 * Provides Flutter method channels for network status and gallery operations
 */
@main
@objc class AppDelegate: FlutterAppDelegate {
  // Network monitoring properties
  var networkMonitor: NWPathMonitor?
  var networkEventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    DispatchQueue.main.async {
      if let controller = self.window?.rootViewController as? FlutterViewController {
        // Set up network connectivity channels
        let networkChannel = FlutterMethodChannel(name: "com.rabee.omran.network", binaryMessenger: controller.binaryMessenger)
        let networkEventChannel = FlutterEventChannel(name: "com.rabee.omran.network/events", binaryMessenger: controller.binaryMessenger)

        // Initialize network path monitor
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        self.networkMonitor = monitor

        // Handle network type requests
        networkChannel.setMethodCallHandler { (call, result) in
            if call.method == "getNetworkType" {
                let type = AppDelegate.getNetworkType(monitor: monitor)
                result(type)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // Set up network event stream for real-time updates
        networkEventChannel.setStreamHandler(NetworkStreamHandler(monitor: monitor, queue: queue))
        monitor.start(queue: queue)

        // Set up gallery save channel
        let galleryChannel = FlutterMethodChannel(name: "com.rabee.omran.gallery", binaryMessenger: controller.binaryMessenger)
        galleryChannel.setMethodCallHandler { (call, result) in
            if call.method == "saveImageToGallery" {
                // Extract URL and filename from arguments
                guard let args = call.arguments as? [String: Any],
                      let urlString = args["url"] as? String,
                      let fileName = args["fileName"] as? String,
                      let url = URL(string: urlString) else {
                    result(false)
                    return
                }
                AppDelegate.saveImageToGallery(url: url, fileName: fileName, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /**
   * Get current network connection type (wifi, ethernet, mobile, or offline)
   */
  static func getNetworkType(monitor: NWPathMonitor) -> String {
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

  /**
   * Download image from URL and save to photo library
   * Handles permissions and background download
   */
  static func saveImageToGallery(url: URL, fileName: String, result: @escaping FlutterResult) {
      // Download image data from URL
      URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data, error == nil, let image = UIImage(data: data) else {
              result(false)
              return
          }
          // Request photo library permission
          PHPhotoLibrary.requestAuthorization { status in
              guard status == .authorized else {
                  result(false)
                  return
              }
              // Save image to photo library
              PHPhotoLibrary.shared().performChanges({
                  PHAssetChangeRequest.creationRequestForAsset(from: image)
              }) { success, error in
                  result(success && error == nil)
              }
          }
      }.resume()
  }
}

/**
 * NetworkStreamHandler manages real-time network connectivity updates
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
            events(type)
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
