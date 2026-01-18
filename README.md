# Snap Share

[![pub package](https://img.shields.io/pub/v/snap_share.svg)](https://pub.dev/packages/snap_share)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Share images and content to Snapchat using Creative Kit. Supports both iOS (SCSDKCreativeKit) and Android (Creative Kit Lite).

## Features

- **Share photos** - Share images as Snap backgrounds
- **Share videos** - Share videos to Snapchat (iOS only)
- **Sticker support** - Add sticker overlays to your shares
- **Captions** - Include text captions
- **Attachment URLs** - Attach links to your snaps (iOS only)
- **Installation check** - Verify Snapchat is installed

## Platform Support

| Feature | iOS | Android |
|---------|-----|---------|
| Share Photo | ✅ | ✅ |
| Share Video | ✅ | ❌ |
| Sticker Overlay | ✅ | ✅ |
| Caption | ✅ | ✅ |
| Attachment URL | ✅ | ❌ |
| Camera with Sticker | ✅ | ❌ |

## Installation

Add `snap_share` to your `pubspec.yaml`:

```yaml
dependencies:
  snap_share: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### iOS Setup

1. **Add SnapSDK to your Podfile:**

Add the following to your `ios/Podfile`:

```ruby
pod 'SnapSDK/SCSDKCreativeKit', '~> 2.0'
```

2. **Configure URL schemes in `Info.plist`:**

Add these entries to your `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>snapchat</string>
</array>

<key>SCSDKClientId</key>
<string>YOUR_SNAP_KIT_CLIENT_ID</string>
```

3. **Register your app with Snap Kit:**

Go to the [Snap Kit Developer Portal](https://kit.snapchat.com/) and create an app to get your Client ID.

4. **Add URL Type for callback (optional):**

In Xcode, go to your target's Info tab and add a URL Type with your app's custom scheme.

### Android Setup

1. **Add FileProvider to `AndroidManifest.xml`:**

Add the following inside the `<application>` tag in `android/app/src/main/AndroidManifest.xml`:

```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

2. **Create `res/xml/file_paths.xml`:**

Create the file `android/app/src/main/res/xml/file_paths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <cache-path name="cache" path="." />
    <files-path name="files" path="." />
    <external-path name="external" path="." />
</paths>
```

3. **Add package query (Android 11+):**

Add the following to your `AndroidManifest.xml` outside the `<application>` tag:

```xml
<queries>
    <package android:name="com.snapchat.android" />
</queries>
```

## Usage

### Check if Snapchat is Installed

```dart
import 'package:snap_share/snap_share.dart';

final isInstalled = await SnapShare.isSnapchatInstalled();
if (!isInstalled) {
  print('Please install Snapchat');
}
```

### Share a Photo

```dart
await SnapShare.sharePhoto(
  imagePath: '/path/to/image.png',
  caption: 'Check this out!',
  attachmentUrl: 'https://yourapp.com/share', // iOS only
);
```

### Share with Sticker Overlay

```dart
await SnapShare.sharePhoto(
  imagePath: '/path/to/background.png',
  stickerPath: '/path/to/sticker.png',
  caption: 'With sticker!',
);
```

### Share a Video (iOS only)

```dart
await SnapShare.shareVideo(
  videoPath: '/path/to/video.mp4',
  caption: 'My video',
);
```

### Open Camera with Sticker (iOS only)

```dart
await SnapShare.openCameraWithSticker(
  stickerPath: '/path/to/sticker.png',
  caption: 'My app sticker!',
);
```

## Error Handling

The plugin provides a custom `SnapShareException` for better error handling:

```dart
try {
  await SnapShare.sharePhoto(imagePath: imagePath);
} on SnapShareException catch (e) {
  print('Share failed: ${e.message}');
  print('Error code: ${e.code}');
} on UnsupportedError catch (e) {
  print('Feature not supported on this platform');
} on ArgumentError catch (e) {
  print('Invalid arguments: $e');
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `SNAPCHAT_NOT_INSTALLED` | Snapchat is not installed on the device |
| `SHARE_FAILED` | The share operation failed |
| `INVALID_ARGUMENTS` | Invalid parameters were provided |
| `NO_ACTIVITY` | (Android) Activity not available |
| `UNSUPPORTED` | Feature not supported on this platform |

## API Reference

### `SnapShare.isSnapchatInstalled()`

Returns `Future<bool>` indicating if Snapchat is installed.

### `SnapShare.sharePhoto()`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `imagePath` | `String` | ✅ | Path to the image file |
| `caption` | `String?` | ❌ | Caption text |
| `attachmentUrl` | `String?` | ❌ | URL to attach (iOS only) |
| `stickerPath` | `String?` | ❌ | Path to sticker image |

### `SnapShare.shareVideo()` (iOS only)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `videoPath` | `String` | ✅ | Path to the video file |
| `caption` | `String?` | ❌ | Caption text |
| `attachmentUrl` | `String?` | ❌ | URL to attach |

### `SnapShare.openCameraWithSticker()` (iOS only)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stickerPath` | `String?` | ❌ | Path to sticker image |
| `caption` | `String?` | ❌ | Caption text |

## Requirements

- iOS 12.0 or later
- Android API 21 (Lollipop) or later
- Snapchat app installed on the device

## Example

Check out the [example](example/) directory for a complete sample app demonstrating all features.

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created by Luca Kramberger
