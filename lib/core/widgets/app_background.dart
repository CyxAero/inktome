/// A dot-grid background that sits behind every screen.
///
/// Use this instead of relying on Scaffold's backgroundColor.
/// The grid is drawn once with CustomPainter and cached by
/// RepaintBoundary — it costs nothing after the first frame.
///
/// **Pattern A:** texture behind the body only
/// ```dart
/// Scaffold(
///   backgroundColor: Colors.transparent,
///   appBar: AppBar(...),
///   body: AppBackground(child: YourContent()),
/// )
/// ```
///
/// **Pattern B:** texture behind everything including the app bar
/// ```dart
/// AppBackground(
///   child: Scaffold(
///     backgroundColor: Colors.transparent,
///     appBar: AppBar(...),
///     body: YourContent(),
///   ),
/// )
/// ```
///
/// Pattern B is recommended — the app bar will feel part of
/// the same surface rather than floating above it.

import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,

    /// Override the background colour for a specific screen.
    /// Defaults to the theme's scaffold background (white or black).
    this.backgroundColor,

    /// Radius of each dot in logical pixels.
    /// 1.5 is subtle and notebook-like. 2.5 starts to feel intentional.
    this.dotRadius = 1.5,

    /// Distance between dot centres in logical pixels.
    /// 20 matches a standard dotted notebook grid (approx. 5mm at 96dpi).
    /// Increase for a more airy feel, decrease for a denser grid.
    this.dotSpacing = 20.0,

    /// Opacity of the dots. 0.0 is invisible, 1.0 is fully opaque.
    /// 0.06 is barely perceptible — felt more than seen.
    /// 0.12 is clearly visible but still tasteful.
    this.dotOpacity = 0.06,
  });

  final Widget child;
  final Color? backgroundColor;
  final double dotRadius;
  final double dotSpacing;
  final double dotOpacity;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    // Dots are dark on light backgrounds, light on dark backgrounds.
    // computeLuminance() returns 0.0 (black) to 1.0 (white).
    // Below 0.5 is considered dark — use white dots.
    final isDark = bgColor.computeLuminance() < 0.5;
    final dotColor = isDark ? InktomeColors.white : InktomeColors.black;

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          // ── Dot grid ──────────────────────────────────────────
          // RepaintBoundary tells Flutter to rasterise this layer
          // to a GPU texture after the first frame. Since the dots
          // never move or change, Flutter never repaints this —
          // it just composites the cached texture every frame.
          // Cost after frame one: essentially zero.
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _DotGridPainter(
                  dotColor: dotColor,
                  dotRadius: dotRadius,
                  dotSpacing: dotSpacing,
                  dotOpacity: dotOpacity,
                ),
              ),
            ),
          ),

          // ── Vignette ──────────────────────────────────────────
          // Fades the dots towards all four edges evenly.
          //
          // Why a CustomPainter and not DecoratedBox + RadialGradient?
          // RadialGradient.radius is a fraction of the shortest side
          // of the widget. On a phone (tall and narrow), that means
          // the gradient circle hits the top and bottom edges long
          // before reaching the left and right — leaving the sides
          // looking as faded as the centre.
          //
          // Instead, we pass radius: 1.0 and call createShader(rect)
          // where rect is the full canvas. Flutter maps the gradient's
          // coordinate space onto that rectangle, stretching the circle
          // into an oval that reaches all four edges at the same
          // relative distance. The fade is even on every side.
          //
          // IgnorePointer ensures this layer never intercepts taps.
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _VignettePainter(backgroundColor: bgColor),
                ),
              ),
            ),
          ),

          // Screen content sits above both the dots and the vignette.
          child,
        ],
      ),
    );
  }
}

// ── Dot grid painter ──────────────────────────────────────────
//
// Walks the canvas in a regular grid, painting a filled circle
// at each intersection. Simple and fast — no trigonometry,
// no randomness, no state.
//
// shouldRepaint returns false in normal usage because the
// dot properties never change at runtime. The check is there
// as a safety net in case you ever wire the parameters to
// a live control (e.g. a settings slider).

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({
    required this.dotColor,
    required this.dotRadius,
    required this.dotSpacing,
    required this.dotOpacity,
  });

  final Color dotColor;
  final double dotRadius;
  final double dotSpacing;
  final double dotOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor.withValues(alpha: dotOpacity)
      ..style = PaintingStyle.fill;

    // Start half a spacing unit in from each edge so the first
    // dot is centred in its cell rather than clipped at the border.
    double y = dotSpacing / 2;
    while (y < size.height) {
      double x = dotSpacing / 2;
      while (x < size.width) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
        x += dotSpacing;
      }
      y += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor ||
        oldDelegate.dotRadius != dotRadius ||
        oldDelegate.dotSpacing != dotSpacing ||
        oldDelegate.dotOpacity != dotOpacity;
  }
}

// ── Vignette painter ──────────────────────────────────────────
//
// HOW THE OVAL STRETCHING WORKS:
//
// RadialGradient has a radius property that operates in a
// normalised coordinate space — 1.0 means "reach the edge of
// the bounding rect passed to createShader()".
//
// By passing the full canvas rect to createShader(), we tell
// Flutter: "map this gradient's 0.0–1.0 space onto this
// specific rectangle." The gradient that would normally be a
// circle becomes an oval that exactly fits the screen, reaching
// every edge at the same normalised distance (1.0).
//
// The result: the fade is visually even on all four sides
// regardless of screen aspect ratio. This is the same technique
// iOS uses for its background vignettes.

class _VignettePainter extends CustomPainter {
  const _VignettePainter({required this.backgroundColor});

  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    // rect covers the entire canvas — passed to createShader()
    // to drive the oval stretching described above.
    final rect = Offset.zero & size;

    // radius: 1.0 means the gradient reaches the edge of rect.
    // Because rect is the full canvas, the gradient fills the
    // screen exactly — stretched to the screen's aspect ratio.
    //
    // Tune the stops to change the fade shape:
    //   0.45 → the inner 45% of the screen stays fully transparent
    //   0.75 → halfway through the fade zone
    //   1.0  → the screen edge (always 1.0)
    //
    // Tune the opacities to change the fade strength:
    //   0.0  → fully transparent (always keep centre at 0.0)
    //   0.55 → mid-fade opacity
    //   0.90 → how solid the very edges are
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        backgroundColor.withValues(alpha: 0.0),
        backgroundColor.withValues(alpha: 0.55),
        backgroundColor.withValues(alpha: 0.90),
      ],
      stops: const [0.45, 0.75, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    // A single drawRect call fills the canvas with the
    // oval-stretched gradient. One GPU draw call, very fast.
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_VignettePainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
}
