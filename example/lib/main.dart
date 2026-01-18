import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snap_share/snap_share.dart';

void main() {
  runApp(const SnapShareExampleApp());
}

class SnapShareExampleApp extends StatelessWidget {
  const SnapShareExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Share Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  bool _isSnapchatInstalled = false;
  bool _isLoading = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _checkSnapchatInstalled();
  }

  Future<void> _checkSnapchatInstalled() async {
    final isInstalled = await SnapShare.isSnapchatInstalled();
    setState(() {
      _isSnapchatInstalled = isInstalled;
    });
  }

  Future<void> _sharePhoto() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      // In a real app, you would get the image path from your app's data
      // For this example, we'll show what the call would look like
      await SnapShare.sharePhoto(
        imagePath: '/path/to/your/image.png',
        caption: 'Shared from my app!',
        attachmentUrl: 'https://example.com',
      );

      setState(() {
        _statusMessage = 'Successfully opened Snapchat!';
        _isError = false;
      });
    } on SnapShareException catch (e) {
      setState(() {
        _statusMessage = 'Share failed: ${e.message}';
        _isError = true;
      });
    } on ArgumentError catch (e) {
      setState(() {
        _statusMessage = 'Invalid argument: ${e.message}';
        _isError = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareWithSticker() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      await SnapShare.sharePhoto(
        imagePath: '/path/to/background.png',
        stickerPath: '/path/to/sticker.png',
        caption: 'With sticker overlay!',
      );

      setState(() {
        _statusMessage = 'Successfully opened Snapchat with sticker!';
        _isError = false;
      });
    } on SnapShareException catch (e) {
      setState(() {
        _statusMessage = 'Share failed: ${e.message}';
        _isError = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareVideo() async {
    if (!Platform.isIOS) {
      setState(() {
        _statusMessage = 'Video sharing is only supported on iOS';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      await SnapShare.shareVideo(
        videoPath: '/path/to/video.mp4',
        caption: 'Check out this video!',
      );

      setState(() {
        _statusMessage = 'Successfully opened Snapchat with video!';
        _isError = false;
      });
    } on SnapShareException catch (e) {
      setState(() {
        _statusMessage = 'Share failed: ${e.message}';
        _isError = true;
      });
    } on UnsupportedError catch (e) {
      setState(() {
        _statusMessage = e.message ?? 'Video sharing not supported';
        _isError = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openCamera() async {
    if (!Platform.isIOS) {
      setState(() {
        _statusMessage = 'Camera sticker is only supported on iOS';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      await SnapShare.openCameraWithSticker(
        stickerPath: '/path/to/sticker.png',
        caption: 'My app sticker!',
      );

      setState(() {
        _statusMessage = 'Successfully opened Snapchat camera!';
        _isError = false;
      });
    } on SnapShareException catch (e) {
      setState(() {
        _statusMessage = 'Failed: ${e.message}';
        _isError = true;
      });
    } on UnsupportedError catch (e) {
      setState(() {
        _statusMessage = e.message ?? 'Camera sticker not supported';
        _isError = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap Share'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Snapchat status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isSnapchatInstalled
                            ? Colors.yellow
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isSnapchatInstalled ? Icons.check : Icons.close,
                        color: _isSnapchatInstalled
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Snapchat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _isSnapchatInstalled
                                ? 'Installed and ready'
                                : 'Not installed',
                            style: TextStyle(
                              color: _isSnapchatInstalled
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _checkSnapchatInstalled,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Platform info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Running on ${Platform.operatingSystem.toUpperCase()}. '
                        'Some features are iOS-only.',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Share buttons
            const Text(
              'Share Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _ShareButton(
              icon: Icons.photo,
              label: 'Share Photo',
              subtitle: 'iOS & Android',
              onPressed: _isLoading ? null : _sharePhoto,
            ),

            const SizedBox(height: 8),

            _ShareButton(
              icon: Icons.layers,
              label: 'Share with Sticker',
              subtitle: 'iOS & Android',
              onPressed: _isLoading ? null : _shareWithSticker,
            ),

            const SizedBox(height: 8),

            _ShareButton(
              icon: Icons.videocam,
              label: 'Share Video',
              subtitle: 'iOS only',
              onPressed: _isLoading ? null : _shareVideo,
              enabled: Platform.isIOS,
            ),

            const SizedBox(height: 8),

            _ShareButton(
              icon: Icons.camera_alt,
              label: 'Open Camera with Sticker',
              subtitle: 'iOS only',
              onPressed: _isLoading ? null : _openCamera,
              enabled: Platform.isIOS,
            ),

            const SizedBox(height: 24),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // Status message
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isError ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isError ? Colors.red[200]! : Colors.green[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isError ? Icons.error_outline : Icons.check_circle,
                      color: _isError ? Colors.red[700] : Colors.green[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _isError ? Colors.red[900] : Colors.green[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Feature matrix
            const Text(
              'Feature Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTable() {
    return Table(
      border: TableBorder.all(
        color: Colors.grey[300]!,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          children: const [
            _TableCell(text: 'Feature', isHeader: true),
            _TableCell(text: 'iOS', isHeader: true),
            _TableCell(text: 'Android', isHeader: true),
          ],
        ),
        const TableRow(children: [
          _TableCell(text: 'Share Photo'),
          _TableCell(text: '✅', isCenter: true),
          _TableCell(text: '✅', isCenter: true),
        ]),
        const TableRow(children: [
          _TableCell(text: 'Share Video'),
          _TableCell(text: '✅', isCenter: true),
          _TableCell(text: '❌', isCenter: true),
        ]),
        const TableRow(children: [
          _TableCell(text: 'Sticker Overlay'),
          _TableCell(text: '✅', isCenter: true),
          _TableCell(text: '✅', isCenter: true),
        ]),
        const TableRow(children: [
          _TableCell(text: 'Caption'),
          _TableCell(text: '✅', isCenter: true),
          _TableCell(text: '✅', isCenter: true),
        ]),
        const TableRow(children: [
          _TableCell(text: 'Attachment URL'),
          _TableCell(text: '✅', isCenter: true),
          _TableCell(text: '❌', isCenter: true),
        ]),
        const TableRow(children: [
          _TableCell(text: 'Camera Sticker'),
          _TableCell(text: '✅', isCenter: true),
          _TableCell(text: '❌', isCenter: true),
        ]),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? Colors.yellow[700] : Colors.grey,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: enabled ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: enabled ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: enabled ? null : Colors.grey,
        ),
        onTap: enabled ? onPressed : null,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.text,
    this.isHeader = false,
    this.isCenter = false,
  });

  final String text;
  final bool isHeader;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: isCenter ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
