import Flutter
import UIKit

/// Main plugin class for the snap_share Flutter plugin.
///
/// This class handles method calls from Flutter and delegates the actual
/// Snapchat sharing logic to `SnapShareHandler`.
public class SnapSharePlugin: NSObject, FlutterPlugin {
    private let snapHandler = SnapShareHandler()
    
    /// Registers the plugin with the Flutter engine.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.snap_share.package/channel",
            binaryMessenger: registrar.messenger()
        )
        let instance = SnapSharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    /// Handles method calls from Flutter.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isInstalled":
            result(snapHandler.isSnapchatInstalled())
            
        case "sharePhoto":
            handleSharePhoto(call: call, result: result)
            
        case "shareVideo":
            handleShareVideo(call: call, result: result)
            
        case "openCamera":
            handleOpenCamera(call: call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Method Handlers
    
    /// Handles the sharePhoto method call.
    private func handleSharePhoto(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String,
              let image = UIImage(contentsOfFile: imagePath) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid imagePath",
                details: nil
            ))
            return
        }
        
        let caption = args["caption"] as? String
        let attachmentUrl = args["attachmentUrl"] as? String
        var sticker: UIImage? = nil
        
        if let stickerPath = args["stickerPath"] as? String, !stickerPath.isEmpty {
            sticker = UIImage(contentsOfFile: stickerPath)
        }
        
        snapHandler.sharePhoto(
            image,
            caption: caption,
            attachmentUrl: attachmentUrl,
            sticker: sticker
        ) { error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(
                        code: "SHARE_FAILED",
                        message: error.localizedDescription,
                        details: nil
                    ))
                } else {
                    result(nil)
                }
            }
        }
    }
    
    /// Handles the shareVideo method call.
    private func handleShareVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let videoPath = args["videoPath"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid videoPath",
                details: nil
            ))
            return
        }
        
        let videoUrl = URL(fileURLWithPath: videoPath)
        let caption = args["caption"] as? String
        let attachmentUrl = args["attachmentUrl"] as? String
        
        snapHandler.shareVideo(
            videoUrl,
            caption: caption,
            attachmentUrl: attachmentUrl
        ) { error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(
                        code: "SHARE_FAILED",
                        message: error.localizedDescription,
                        details: nil
                    ))
                } else {
                    result(nil)
                }
            }
        }
    }
    
    /// Handles the openCamera method call.
    private func handleOpenCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let caption = args?["caption"] as? String
        var sticker: UIImage? = nil
        
        if let stickerPath = args?["stickerPath"] as? String, !stickerPath.isEmpty {
            sticker = UIImage(contentsOfFile: stickerPath)
        }
        
        snapHandler.openCamera(
            sticker: sticker,
            caption: caption
        ) { error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(
                        code: "CAMERA_FAILED",
                        message: error.localizedDescription,
                        details: nil
                    ))
                } else {
                    result(nil)
                }
            }
        }
    }
}
