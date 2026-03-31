import 'dart:math' as math;

import 'package:flutter/material.dart';

// MARK: DASHED BORDER
/// Applies a dashed border on top of its child.
///
/// The border is drawn as a superellipse (squircle) with the given radius.
/// Use this together with [SquircleClip] and a [ColoredBox] to achieve
/// a dashed‑border container with a solid background.
///
/// Example:
/// ```dart
/// DashedBorder(
///   color: Colors.black,
///   radius: 16,
///   child: Text('Hello'),
/// )
/// ```
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    this.dashLength = 10.0,
    this.dashGap = 6.0,
    required this.child,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
      ),
      child: child,
    );
  }
}

// MARK: DASHED BORDER PAINTER
/// A [CustomPainter] that draws a dashed border following a superellipse (squircle) shape.
///
/// The border is drawn **inside** the widget’s bounds, inset by half the stroke width,
/// so the full stroke is visible. The radius is clamped to half the smallest side,
/// which produces a perfect circle when the widget is square and `radius` is large.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    this.dashLength = 8.0,
    this.dashGap = 5.0,
  });

  final Color color; // Colour of the dashes
  final double radius; // Corner radius (superellipse)
  final double strokeWidth; // Thickness of the border
  final double dashLength; // Length of each dash
  final double dashGap; // Gap between dashes

  @override
  void paint(Canvas canvas, Size size) {
    // Inset by half the stroke width so the border is not clipped.
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    // Clamp radius to half the shortest side → gives a circle on square widgets.
    final clampedRadius = math.min(
      radius,
      math.min(rect.width, rect.height) / 2,
    );

    // Build the superellipse shape.
    final rse = RSuperellipse.fromRectAndRadius(
      rect,
      Radius.circular(clampedRadius),
    );

    // Convert the shape to a [Path] so we can iterate over its metrics.
    final path = Path()..addRSuperellipse(rse);

    // Paint for the dashes.
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Walk each contour (there’s only one here) and draw dashes.
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      bool drawing = true; // true = dash, false = gap

      while (distance < metric.length) {
        final segLen = drawing ? dashLength : dashGap;
        final end = (distance + segLen).clamp(0.0, metric.length);

        if (drawing) {
          // Extract the segment path and draw it.
          canvas.drawPath(metric.extractPath(distance, end), paint);
        }

        distance = end;
        drawing = !drawing; // toggle between dash and gap
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.dashGap != dashGap;
}

// MARK: SQUIRCLE CLIP
/// Clips its child to a superellipse (squircle) shape.
///
/// Use this to make any widget (e.g., a [ColoredBox]) take the shape
/// of a squircle with the given radius.
///
/// Example:
/// ```dart
/// SquircleClip(
///   radius: 16,
///   child: ColoredBox(color: Colors.blue, child: ...),
/// )
/// ```
class SquircleClip extends StatelessWidget {
  const SquircleClip({super.key, required this.radius, required this.child});

  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }
}
