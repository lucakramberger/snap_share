/// A Flutter plugin to share content to Snapchat.
///
/// This plugin uses Snapchat's Creative Kit to share photos, videos,
/// and stickers to Snapchat's camera preview.
///
/// ## Platform Support
///
/// | Feature | iOS | Android |
/// |---------|-----|---------|
/// | Share Photo | ✅ | ✅ |
/// | Share Video | ✅ | ❌ |
/// | Sticker Overlay | ✅ | ✅ |
/// | Caption | ✅ | ✅ |
/// | Attachment URL | ✅ | ❌ |
/// | Camera with Sticker | ✅ | ❌ |
///
/// ## Example
///
/// ```dart
/// import 'package:snap_share/snap_share.dart';
///
/// // Check if Snapchat is installed
/// final isInstalled = await SnapShare.isSnapchatInstalled();
///
/// // Share a photo
/// await SnapShare.sharePhoto(
///   imagePath: '/path/to/image.png',
///   caption: 'Check this out!',
/// );
/// ```
library snap_share;

export 'src/snap_share_impl.dart';
