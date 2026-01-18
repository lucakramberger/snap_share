import 'dart:io';

import 'package:flutter/services.dart';

/// A utility class to share content to Snapchat.
///
/// Uses Snapchat's Creative Kit on iOS (SCSDKCreativeKit) and
/// Creative Kit Lite intents on Android.
///
/// ## Prerequisites
///
/// ### iOS
/// - Add SnapSDK Creative Kit to your Podfile
/// - Configure URL schemes in Info.plist
/// - Add your Snap Kit client ID
///
/// ### Android
/// - Add FileProvider configuration
/// - Configure Snapchat package queries in AndroidManifest.xml
///
/// ## Example
///
/// ```dart
/// try {
///   await SnapShare.sharePhoto(
///     imagePath: '/path/to/image.png',
///     caption: 'Check this out!',
///     attachmentUrl: 'https://yourapp.com/share',
///   );
/// } catch (e) {
///   print('Share failed: $e');
/// }
/// ```
class SnapShare {
  SnapShare._();

  /// The method channel used to communicate with native code.
  static const MethodChannel _channel = MethodChannel(
    'com.snap_share.package/channel',
  );

  /// Checks if Snapchat is installed on the device.
  ///
  /// Returns `true` if Snapchat is available for sharing, `false` otherwise.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isInstalled = await SnapShare.isSnapchatInstalled();
  /// if (!isInstalled) {
  ///   print('Please install Snapchat');
  /// }
  /// ```
  static Future<bool> isSnapchatInstalled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isInstalled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Shares a photo to Snapchat's camera preview.
  ///
  /// The photo will be used as the background, and the user can
  /// add their own elements before posting.
  ///
  /// ## Parameters
  ///
  /// * [imagePath] - The file path to the image to share (required).
  ///   The file must exist and be readable.
  /// * [caption] - Optional caption text to display on the snap.
  /// * [attachmentUrl] - Optional URL to attach to the snap (iOS only).
  /// * [stickerPath] - Optional file path to a sticker image overlay.
  ///
  /// ## Throws
  ///
  /// * [SnapShareException] if the share fails.
  /// * [ArgumentError] if [imagePath] is empty or the file doesn't exist.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await SnapShare.sharePhoto(
  ///   imagePath: imageFile.path,
  ///   caption: 'Having a great time!',
  ///   attachmentUrl: 'https://myapp.com',
  /// );
  /// ```
  static Future<void> sharePhoto({
    required String imagePath,
    String? caption,
    String? attachmentUrl,
    String? stickerPath,
  }) async {
    // Validate image path
    if (imagePath.isEmpty) {
      throw ArgumentError('imagePath cannot be empty');
    }

    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw ArgumentError('Image file does not exist: $imagePath');
    }

    // Validate sticker path if provided
    if (stickerPath != null && stickerPath.isNotEmpty) {
      final stickerFile = File(stickerPath);
      if (!await stickerFile.exists()) {
        throw ArgumentError('Sticker file does not exist: $stickerPath');
      }
    }

    try {
      await _channel.invokeMethod('sharePhoto', {
        'imagePath': imagePath,
        'caption': caption,
        'attachmentUrl': attachmentUrl,
        'stickerPath': stickerPath,
      });
    } on PlatformException catch (e) {
      throw SnapShareException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }

  /// Shares a video to Snapchat's camera preview.
  ///
  /// ## Parameters
  ///
  /// * [videoPath] - The file path to the video to share (required).
  /// * [caption] - Optional caption text to display.
  /// * [attachmentUrl] - Optional URL to attach to the snap.
  ///
  /// ## Throws
  ///
  /// * [SnapShareException] if the share fails.
  /// * [ArgumentError] if [videoPath] is empty or the file doesn't exist.
  /// * [UnsupportedError] if called on Android.
  ///
  /// ## Note
  ///
  /// Video sharing is currently only supported on iOS.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await SnapShare.shareVideo(
  ///   videoPath: videoFile.path,
  ///   caption: 'Check out this video!',
  /// );
  /// ```
  static Future<void> shareVideo({
    required String videoPath,
    String? caption,
    String? attachmentUrl,
  }) async {
    if (!Platform.isIOS) {
      throw UnsupportedError(
        'Video sharing is only supported on iOS. '
        'Current platform: ${Platform.operatingSystem}',
      );
    }

    if (videoPath.isEmpty) {
      throw ArgumentError('videoPath cannot be empty');
    }

    final videoFile = File(videoPath);
    if (!await videoFile.exists()) {
      throw ArgumentError('Video file does not exist: $videoPath');
    }

    try {
      await _channel.invokeMethod('shareVideo', {
        'videoPath': videoPath,
        'caption': caption,
        'attachmentUrl': attachmentUrl,
      });
    } on PlatformException catch (e) {
      throw SnapShareException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }

  /// Opens Snapchat's camera with an optional sticker overlay.
  ///
  /// This opens the camera without a background image, allowing
  /// the user to take a new photo/video with the sticker attached.
  ///
  /// ## Parameters
  ///
  /// * [stickerPath] - Optional file path to a sticker image.
  /// * [caption] - Optional caption text.
  ///
  /// ## Throws
  ///
  /// * [SnapShareException] if opening the camera fails.
  /// * [UnsupportedError] if called on Android.
  ///
  /// ## Note
  ///
  /// This method is currently only supported on iOS.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await SnapShare.openCameraWithSticker(
  ///   stickerPath: stickerFile.path,
  ///   caption: 'My app sticker!',
  /// );
  /// ```
  static Future<void> openCameraWithSticker({
    String? stickerPath,
    String? caption,
  }) async {
    if (!Platform.isIOS) {
      throw UnsupportedError(
        'Camera sticker is only supported on iOS. '
        'Current platform: ${Platform.operatingSystem}',
      );
    }

    // Validate sticker path if provided
    if (stickerPath != null && stickerPath.isNotEmpty) {
      final stickerFile = File(stickerPath);
      if (!await stickerFile.exists()) {
        throw ArgumentError('Sticker file does not exist: $stickerPath');
      }
    }

    try {
      await _channel.invokeMethod('openCamera', {
        'stickerPath': stickerPath,
        'caption': caption,
      });
    } on PlatformException catch (e) {
      throw SnapShareException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }
}

/// Exception thrown when a Snapchat share operation fails.
///
/// This exception provides detailed information about what went wrong
/// during the share operation.
///
/// ## Example
///
/// ```dart
/// try {
///   await SnapShare.sharePhoto(imagePath: imagePath);
/// } on SnapShareException catch (e) {
///   print('Share failed: ${e.message}');
///   print('Error code: ${e.code}');
/// }
/// ```
class SnapShareException implements Exception {
  /// Creates a new [SnapShareException].
  const SnapShareException({
    required this.code,
    required this.message,
    this.details,
  });

  /// The error code from the platform.
  ///
  /// Common codes include:
  /// - `SNAPCHAT_NOT_INSTALLED` - Snapchat is not installed
  /// - `SHARE_FAILED` - The share operation failed
  /// - `INVALID_ARGUMENTS` - Invalid parameters were provided
  final String code;

  /// A human-readable error message describing what went wrong.
  final String message;

  /// Additional error details from the platform, if available.
  final dynamic details;

  @override
  String toString() => 'SnapShareException($code): $message';
}
