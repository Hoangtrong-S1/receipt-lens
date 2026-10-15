import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../services/ocr_service.dart';
import 'review_receipt_screen.dart';

class ReceiptCameraScreen extends StatefulWidget {
  const ReceiptCameraScreen({super.key});
  @override State<ReceiptCameraScreen> createState() => _ReceiptCameraScreenState();
}

class _ReceiptCameraScreenState extends State<ReceiptCameraScreen> {
  CameraController? _camera;
  String? _error;
  bool _busy = false;
  FlashMode _flash = FlashMode.off;

  @override
  void initState() { super.initState(); _startCamera(); }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();
      final selected = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(selected, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) { await controller.dispose(); return; }
      setState(() => _camera = controller);
    } catch (_) {
      if (mounted) setState(() => _error = 'Camera is unavailable. Check camera permission and try again.');
    }
  }

  Future<void> _toggleFlash() async {
    final camera = _camera;
    if (camera == null) return;
    _flash = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await camera.setFlashMode(_flash);
    if (mounted) setState(() {});
  }

  Future<void> _takePhoto() async {
    final camera = _camera;
    if (camera == null || _busy) return;
    setState(() => _busy = true);
    try {
      final image = await camera.takePicture();
      final cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 92,
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'Crop receipt', lockAspectRatio: false),
          IOSUiSettings(title: 'Crop receipt'),
        ],
      );
      if (cropped == null || !mounted) return;
      final service = OcrService();
      try {
        final draft = await service.scan(cropped.path);
        if (mounted) await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReviewReceiptScreen(draft: draft)));
      } finally {
        await service.dispose();
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not scan this receipt. Please try another photo.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() { _camera?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Scaffold(appBar: AppBar(), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center))));
    if (_camera == null || !_camera!.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Stack(children: [
        GestureDetector(
          onTapDown: (details) async {
            final box = context.findRenderObject() as RenderBox;
            final point = box.globalToLocal(details.globalPosition);
            await _camera?.setFocusPoint(Offset(point.dx / box.size.width, point.dy / box.size.height));
          },
          child: Center(child: CameraPreview(_camera!)),
        ),
        const _ReceiptFrame(),
        Positioned(top: 12, left: 12, child: IconButton.filledTonal(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))),
        Positioned(top: 12, right: 12, child: IconButton.filledTonal(onPressed: _toggleFlash, icon: Icon(_flash == FlashMode.off ? Icons.flash_off : Icons.flash_on))),
        const Positioned(top: 72, left: 28, right: 28, child: Text('Keep the whole receipt inside the frame', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 8)]))),
        Positioned(bottom: 40, left: 0, right: 0, child: Center(child: FilledButton.tonalIcon(
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16)),
          onPressed: _busy ? null : _takePhoto,
          icon: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.camera_alt_outlined),
          label: Text(_busy ? 'Reading receipt…' : 'Capture receipt'),
        ))),
      ])),
    );
  }
}

class _ReceiptFrame extends StatelessWidget {
  const _ReceiptFrame();
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Center(child: Container(
    width: MediaQuery.sizeOf(context).width * .82,
    height: MediaQuery.sizeOf(context).height * .63,
    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(18)),
  )));
}
