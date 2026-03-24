import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';

/// A single tab in the main navigation pill (Pill 1).
class NavTab {
  const NavTab({required this.label, required this.path});
  final String label;
  final String path;
}

// MARK: INKTOME NAV BAR (root widget)
/// Floating two-pill navigation bar.
///
/// Pill 1 (left) — main tab switcher with a squircle dashed outline.
/// Pill 2 (right) — contextual actions, always a perfect circle
///
/// ## Height matching
///
/// Both pills sit inside an [IntrinsicHeight] row with
/// [CrossAxisAlignment.stretch]. This means Pill 2 always stretches to
/// exactly Pill 1's height — so when Pill 2 is square (one icon), it's
/// a perfect circle. No hardcoded heights needed.
///
/// Drop this into a [Stack] positioned at the bottom of the screen.
/// The widget handles its own [SafeArea] bottom inset.
class InktomeNavBar extends StatelessWidget {
  const InktomeNavBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = scaffoldColor.computeLuminance() < 0.5;
    final pillBg = isDark
        ? InktomeColors.cardOnBlack
        : InktomeColors.cardOnWhite;
    final pillFg = isDark ? InktomeColors.white : InktomeColors.black;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: InktomeSpacing.lg,
            right: InktomeSpacing.lg,
            bottom: InktomeSpacing.lg,
          ),
          // IntrinsicHeight makes both pills measure their natural height,
          // then stretches both to match the taller one (always Pill 1).
          // This is what gives Pill 2 a perfect circle shape
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // MARK: Pill 1 — main nav
                _MainPill(
                  tabs: tabs,
                  selectedIndex: selectedIndex,
                  onTabSelected: onTabSelected,
                  pillBg: pillBg,
                  pillFg: pillFg,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: SHARED CONSTANTS

/// Squircle corner radius for the outer pill shape and dashed border.
const double _kPillRadius = 16.0;

/// Corner radius for the inner selected-tab highlight chip.
/// Smaller than [_kPillRadius] so it sits visually inset.
const double _kInnerTabRadius = 10.0;

// MARK: MAIN NAV PILL (Pill 1)
/// The left pill containing the tab labels.
///
/// Layout (outer → inner):
///   CustomPaint (dashed squircle border, drawn in foreground)
///     └── ClipRSuperellipse (clips fill to squircle outline)
///           └── ColoredBox (pill background)
///                 └── Padding > Row of [_NavTabItem]
///
/// [IntrinsicHeight] lives in the parent [InktomeNavBar], not here —
/// that's what lets Pill 2 stretch to match this pill's height.
class _MainPill extends StatelessWidget {
  const _MainPill({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.pillBg,
    required this.pillFg,
    required this.isDark,
  });

  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color pillBg;
  final Color pillFg;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color selectedPillBg = isDark
        ? InktomeColors.white
        : InktomeColors.black;

    final Color selectedPillFg = isDark
        ? InktomeColors.black
        : InktomeColors.white;

    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: pillFg,
        radius: _kPillRadius,
      ),
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(_kPillRadius),
        child: ColoredBox(
          color: pillBg,
          child: Padding(
            padding: const EdgeInsets.all(InktomeSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < tabs.length; i++)
                  _NavTabItem(
                    label: tabs[i].label,
                    isSelected: i == selectedIndex,
                    pillFg: pillFg,
                    selectedPillBg: selectedPillBg,
                    selectedPillFg: selectedPillFg,
                    onTap: () => onTabSelected(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: INDIVIDUAL TAB ITEM
/// A single tappable label chip inside Pill 1.
class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.label,
    required this.isSelected,
    required this.pillFg,
    required this.onTap,
    required this.selectedPillBg,
    required this.selectedPillFg,
  });

  final String label;
  final bool isSelected;
  final Color pillFg;
  final VoidCallback onTap;
  final Color selectedPillBg;
  final Color selectedPillFg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: isSelected ? selectedPillBg : Colors.transparent,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(_kInnerTabRadius),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.sm,
          vertical: InktomeSpacing.sm,
        ),
        child: Text(
          label,
          style: InktomeTextStyles.button.copyWith(
            color: isSelected ? selectedPillFg : pillFg,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w400,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// MARK: DASHED BORDER PAINTER
/// Draws a dashed border following an RSuperellipse (squircle) outline.
///
/// Passing [radius: 999] (or any value > half the shortest side) produces
/// a perfect circle on a square widget — the clamp handles it automatically.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;
  final double strokeWidth = 1.5;
  final double dashLength = 8.0;
  final double dashGap = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    // Clamp radius to half the shortest side.
    // This is what turns radius:999 into a perfect circle on a square widget.
    final clampedRadius = math.min(
      radius,
      math.min(rect.width, rect.height) / 2,
    );

    final path = Path()
      ..addRSuperellipse(
        RSuperellipse.fromRectAndRadius(rect, Radius.circular(clampedRadius)),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.dashGap != dashGap;
}
