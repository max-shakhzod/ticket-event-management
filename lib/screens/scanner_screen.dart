// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ticket_event_management/screens/screens.dart';
import 'package:ticket_event_management/theme/colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _controller.stop();
        break;
      default:
        break;
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _hasScanned = true;
    print(rawValue);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(url: rawValue),
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cutOutSize =
        (size.width < 500 || size.height < 500) ? 350.0 : 400.0;
    final borderLength = 40.0;
    final borderWidth = 10.0;
    final borderRadius = 10.0;

    return Stack(
      children: [
        // Semi-transparent overlay
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: cutOutSize,
                  height: cutOutSize,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Corner borders
        Center(
          child: SizedBox(
            width: cutOutSize,
            height: cutOutSize,
            child: CustomPaint(
              painter: _CornerBorderPainter(
                color: customWhite,
                borderLength: borderLength,
                borderWidth: borderWidth,
                borderRadius: borderRadius,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: customWhite,
        title: const Text(
          'Verify Attendance',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat-Regular',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const HomeScreen(),
              ),
              (route) => false,
            );
          },
        ),
        actions: [
          // Flash toggle
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, child) {
              final torchState = value.torchState;
              return IconButton(
                icon: Icon(
                  torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: torchState == TorchState.on
                      ? Colors.amber
                      : Colors.black,
                ),
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
          // Camera flip
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.black),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
        elevation: 0.5,
        shadowColor: Colors.grey[600],
      ),
      body: Container(
        color: const Color.fromARGB(255, 2, 0, 0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Scan from Guest Qr Code to\n verify attendance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat-Regular',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Center(
                        child: Text(
                          'Camera error: ${error.errorCode}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                  _buildScannerOverlay(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the four corner brackets of a QR scan viewport.
class _CornerBorderPainter extends CustomPainter {
  final Color color;
  final double borderLength;
  final double borderWidth;
  final double borderRadius;

  const _CornerBorderPainter({
    required this.color,
    required this.borderLength,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final r = borderRadius;
    final l = borderLength;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, l + r)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..lineTo(l + r, 0),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - l - r, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, l + r),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, h - l - r)
        ..lineTo(0, h - r)
        ..arcToPoint(Offset(r, h), radius: Radius.circular(r))
        ..lineTo(l + r, h),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w - l - r, h)
        ..lineTo(w - r, h)
        ..arcToPoint(Offset(w, h - r), radius: Radius.circular(r))
        ..lineTo(w, h - l - r),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderLength != borderLength ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.borderRadius != borderRadius;
}
