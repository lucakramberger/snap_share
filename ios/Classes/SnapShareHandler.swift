import UIKit
import SCSDKCreativeKit

/// Handles Snapchat Creative Kit interactions.
///
/// This class encapsulates all the logic for sharing content to Snapchat
/// using the SCSDKCreativeKit framework.
class SnapShareHandler: NSObject {
    /// The Snapchat API instance used for sharing.
    private let api = SCSDKSnapAPI()
    
    /// Checks if Snapchat is installed on the device.
    ///
    /// - Returns: `true` if Snapchat is installed and can be opened, `false` otherwise.
    func isSnapchatInstalled() -> Bool {
        guard let url = URL(string: "snapchat://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// Shares a photo to Snapchat's camera preview.
    ///
    /// - Parameters:
    ///   - image: The background image to share.
    ///   - caption: Optional caption text.
    ///   - attachmentUrl: Optional URL to attach to the snap.
    ///   - sticker: Optional sticker image overlay.
    ///   - completion: Callback with optional error.
    func sharePhoto(
        _ image: UIImage,
        caption: String?,
        attachmentUrl: String?,
        sticker: UIImage?,
        completion: @escaping (Error?) -> Void
    ) {
        let photo = SCSDKSnapPhoto(image: image)
        let content = SCSDKPhotoSnapContent(snapPhoto: photo)
        
        // Set caption if provided
        if let caption = caption, !caption.isEmpty {
            content.caption = caption
        }
        
        // Set attachment URL if provided
        if let url = attachmentUrl, !url.isEmpty {
            content.attachmentUrl = url
        }
        
        // Set sticker if provided
        if let stickerImage = sticker {
            let snapSticker = SCSDKSnapSticker(stickerImage: stickerImage)
            // Configure sticker size (can be adjusted based on needs)
            snapSticker.height = 400
            snapSticker.width = 300
            content.sticker = snapSticker
        }
        
        // Start sending to Snapchat
        api.startSending(content) { error in
            completion(error)
        }
    }
    
    /// Shares a video to Snapchat's camera preview.
    ///
    /// - Parameters:
    ///   - videoUrl: The URL of the video file to share.
    ///   - caption: Optional caption text.
    ///   - attachmentUrl: Optional URL to attach to the snap.
    ///   - completion: Callback with optional error.
    func shareVideo(
        _ videoUrl: URL,
        caption: String?,
        attachmentUrl: String?,
        completion: @escaping (Error?) -> Void
    ) {
        let video = SCSDKSnapVideo(videoUrl: videoUrl)
        let content = SCSDKVideoSnapContent(snapVideo: video)
        
        // Set caption if provided
        if let caption = caption, !caption.isEmpty {
            content.caption = caption
        }
        
        // Set attachment URL if provided
        if let url = attachmentUrl, !url.isEmpty {
            content.attachmentUrl = url
        }
        
        // Start sending to Snapchat
        api.startSending(content) { error in
            completion(error)
        }
    }
    
    /// Opens Snapchat's camera with an optional sticker overlay.
    ///
    /// This opens the camera without a background, allowing the user
    /// to take a new photo or video with the sticker attached.
    ///
    /// - Parameters:
    ///   - sticker: Optional sticker image.
    ///   - caption: Optional caption text.
    ///   - completion: Callback with optional error.
    func openCamera(
        sticker: UIImage?,
        caption: String?,
        completion: @escaping (Error?) -> Void
    ) {
        let content = SCSDKNoSnapContent()
        
        // Set caption if provided
        if let caption = caption, !caption.isEmpty {
            content.caption = caption
        }
        
        // Set sticker if provided
        if let stickerImage = sticker {
            content.sticker = SCSDKSnapSticker(stickerImage: stickerImage)
        }
        
        // Start sending to Snapchat
        api.startSending(content) { error in
            completion(error)
        }
    }
}
