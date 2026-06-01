import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:ticket_event_management/db/ticket_repository.dart';
import 'package:ticket_event_management/models/models.dart';
import 'package:ticket_event_management/providers/auth_provider.dart';
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
  late final TicketRepository _repo;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _repo = TicketRepository();
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

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    final scannedBy =
        context.read<AuthProvider>().currentUser?.userId ?? 'unknown';
    final result =
        await _repo.validateAndScanTicket(rawValue, scannedBy: scannedBy);

    if (!mounted) return;

    // push() so ScannerScreen stays beneath in the stack and is resumed when
    // RegisterScreen is popped (camera restarts via lifecycle observer).
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => RegisterScreen(scanResult: result)),
    );

    if (mounted) setState(() => _isProcessing = false);
  }

  Widget _buildLeading(BuildContext context) {
    final role = context.watch<AuthProvider>().role;

    if (role == UserRole.scanner) {
      // Scanner's root: replace back arrow with logout.
      return IconButton(
        icon: const Icon(Icons.logout, color: Colors.black),
        tooltip: 'Sign out',
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          context.read<AuthProvider>().logout();
        },
      );
    }

    // Admin / event manager: normal back to HomeScreen.
    return GestureDetector(
      child: const Icon(Icons.arrow_back_ios, color: Colors.black),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cutOutSize =
        (size.width < 500 || size.height < 500) ? 350.0 : 400.0;
    const borderLength = 40.0;
    const borderWidth = 10.0;
    const borderRadius = 10.0;

    return Stack(
      children: [
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
        leading: _buildLeading(context),
        actions: [
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
                'Scan from Guest QR Code to\nverify attendance',
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
                  if (_isProcessing)
                    const Center(
                      child: CircularProgressIndicator(color: customGreen),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
