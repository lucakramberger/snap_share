import 'package:flutter_test/flutter_test.dart';
import 'package:snap_share/snap_share.dart';

void main() {
  group('SnapShareException', () {
    test('creates exception with correct properties', () {
      const exception = SnapShareException(
        code: 'TEST_ERROR',
        message: 'Test error message',
        details: {'key': 'value'},
      );

      expect(exception.code, 'TEST_ERROR');
      expect(exception.message, 'Test error message');
      expect(exception.details, {'key': 'value'});
    });

    test('toString returns formatted string', () {
      const exception = SnapShareException(
        code: 'SHARE_FAILED',
        message: 'Could not share to Snapchat',
      );

      expect(
        exception.toString(),
        'SnapShareException(SHARE_FAILED): Could not share to Snapchat',
      );
    });

    test('details can be null', () {
      const exception = SnapShareException(
        code: 'ERROR',
        message: 'Error message',
      );

      expect(exception.details, isNull);
    });
  });

  group('SnapShare.sharePhoto', () {
    test('throws ArgumentError for empty imagePath', () async {
      expect(
        () => SnapShare.sharePhoto(imagePath: ''),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('cannot be empty'),
        )),
      );
    });

    test('throws ArgumentError for non-existent file', () async {
      expect(
        () => SnapShare.sharePhoto(imagePath: '/non/existent/path.png'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('does not exist'),
        )),
      );
    });
  });

  group('SnapShare.shareVideo', () {
    test('throws ArgumentError for empty videoPath', () async {
      try {
        await SnapShare.shareVideo(videoPath: '');
        fail('Should have thrown');
      } on ArgumentError catch (e) {
        expect(e.message, contains('cannot be empty'));
      } on UnsupportedError {
        // Expected on non-iOS platforms
      }
    });
  });

  group('SnapShare.openCameraWithSticker', () {
    test('throws ArgumentError for non-existent sticker file', () async {
      try {
        await SnapShare.openCameraWithSticker(
          stickerPath: '/non/existent/sticker.png',
        );
        fail('Should have thrown');
      } on ArgumentError catch (e) {
        expect(e.message, contains('does not exist'));
      } on UnsupportedError {
        // Expected on non-iOS platforms
      }
    });
  });
}
