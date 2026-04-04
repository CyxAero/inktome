import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  // Controller for Camera hardware
  final MobileScannerController _controller = MobileScannerController(
    // Restricting barcode formats to EAN-13 and EAN-8 for book cataloging (ISBN).
    // This makes detection significantly more performant.
    formats: [BarcodeFormat.ean13, BarcodeFormat.ean8],
  );

  @override
  void dispose() {
    // Cleanup camera resources when the widget is disposed (leaving the page)
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define a scanning box window
    final scanWindow = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.40),
      width: size.width * 0.85,
      height: (size.width * 0.85) * 0.70,
    );

    final foregroundColor = isDark ? InktomeColors.white : InktomeColors.black;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. THE CAMERA LAYER
          // This sits at the base of the stack and renders the raw video feed.
          MobileScanner(
            controller: _controller,
            scanWindow: scanWindow,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  _onBarcodeFound(context, code);
                }
              }
            },
          ),

          // 2. THE BACKGROUND OVERLAY (Hole-punch effect)
          // We apply the dimming effect around the box without clouding the camera feed.
          CustomPaint(
            painter: _ScanOverlayPainter(
              scanWindow: scanWindow,
              dimColor: (isDark ? InktomeColors.black : InktomeColors.white)
                  .withValues(alpha: 0.82),
              borderColor: foregroundColor,
            ),
            child: const SizedBox.expand(),
          ),

          // 4. THE INSTRUCTION TEXT
          Positioned(
            top: scanWindow.bottom + InktomeSpacing.lg,
            left: InktomeSpacing.pagePadding,
            right: InktomeSpacing.pagePadding,
            child: Text(
              'ALIGN BARCODE INSIDE THE BOX',
              textAlign: TextAlign.center,
              style: InktomeTextStyles.headingMediumWithColor(
                foregroundColor,
              ).copyWith(fontSize: 20, letterSpacing: 1),
            ),
          ),

          // 5. THE BOTTOM CLOSE BUTTON
          // Positioned near the bottom to stay within easy thumb reach.
          Positioned(
            bottom: size.height * 0.15,
            left: size.width * 0.25,
            right: size.width * 0.25,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: DashedBorder(
                color: foregroundColor,
                radius: InktomeSpacing.radiusPill,
                strokeWidth: 1.5,
                child: SquircleClip(
                  radius: InktomeSpacing.radiusPill,
                  child: ColoredBox(
                    color: isDark ? InktomeColors.black : InktomeColors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: InktomeSpacing.md,
                      ),
                      child: Center(
                        child: Text(
                          'CANCEL',
                          style: InktomeTextStyles.buttonWithColor(
                            foregroundColor,
                          ).copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBarcodeFound(BuildContext context, String code) {
    _controller.stop();
    // Returning the code back to the overlay that pushed this page.
    context.pop(code);
  }
}

/// Simple clipper that creates a hole in the overlay for the scan window
class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter({
    required this.scanWindow,
    required this.dimColor,
    required this.borderColor,
    this.cornerRadius = 48.0, // increase this for a more pronounced squircle
    this.strokeWidth = 3.0,
    this.dashLength = 12.0,
    this.dashGap = 6.0,
  });

  final Rect scanWindow;
  final Color dimColor;
  final Color borderColor;
  final double cornerRadius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    // Build the squircle path for the scan window.
    final squircle = RSuperellipse.fromRectAndRadius(
      scanWindow,
      Radius.circular(cornerRadius),
    );
    final cutoutPath = Path()..addRSuperellipse(squircle);

    // Dim layer — full screen minus the squircle hole.
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final dimPath = Path.combine(
      PathOperation.difference,
      screenPath,
      cutoutPath,
    );
    canvas.drawPath(dimPath, Paint()..color = dimColor);

    // Dashed border — drawn along the squircle path, guaranteed to follow
    // exactly the same shape as the cutout because it uses the same path.
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final metric in cutoutPath.computeMetrics()) {
      double distance = 0.0;
      bool drawing = true;
      while (distance < metric.length) {
        final segLen = drawing ? dashLength : dashGap;
        final end = (distance + segLen).clamp(0.0, metric.length);
        if (drawing) {
          canvas.drawPath(metric.extractPath(distance, end), borderPaint);
        }
        distance = end;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) =>
      old.scanWindow != scanWindow ||
      old.dimColor != dimColor ||
      old.borderColor != borderColor ||
      old.cornerRadius != cornerRadius;
}

// class _ScanWindowClipper extends CustomClipper<Path> {
//   final Rect scanWindow;
//
//   _ScanWindowClipper({required this.scanWindow});
//
//   @override
//   Path getClip(Size size) {
//     // Create full screen path
//     final screenPath = Path()
//       ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//
//     // Create squircle cutout path using RSuperellipse
//     final squircle = RSuperellipse.fromRectAndRadius(
//       scanWindow,
//       const Radius.circular(24.0),
//     );
//     final cutoutPath = Path()..addRSuperellipse(squircle);
//
//     // Subtract cutout from screen
//     return Path.combine(PathOperation.difference, screenPath, cutoutPath);
//   }
//
//   @override
//   bool shouldReclip(covariant _ScanWindowClipper oldDelegate) {
//     return oldDelegate.scanWindow != scanWindow;
//   }
// }
