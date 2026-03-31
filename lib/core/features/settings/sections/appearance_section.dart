import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/theme/theme_notifier.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:provider/provider.dart';

final _cardRadius = 18.0;

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({
    super.key,
    required this.textColor,
    required this.currentMode,
  });

  final Color textColor;
  final ThemeMode currentMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'appearance',
          style: InktomeTextStyles.headingSmallWithColor(textColor),
        ),
        SizedBox(height: InktomeSpacing.md),
        _ThemeSelector(currentMode: currentMode),
      ],
    );
  }
}

// MARK: THEME SELECTOR
/// Three side-by-side preview cards — light, dark, system.
/// The selected one gets a dashed border. Tapping any card applies
/// the theme immediately via ThemeNotifier.
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.currentMode});

  final ThemeMode currentMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeCard(
          mode: ThemeMode.light,
          label: 'light',
          isSelected: currentMode == ThemeMode.light,
          onTap: () => context.read<ThemeNotifier>().setMode(ThemeMode.light),
        ),
        const SizedBox(width: InktomeSpacing.md),
        _ThemeCard(
          mode: ThemeMode.dark,
          label: 'dark',
          isSelected: currentMode == ThemeMode.dark,
          onTap: () => context.read<ThemeNotifier>().setMode(ThemeMode.dark),
        ),
        const SizedBox(width: InktomeSpacing.md),
        _ThemeCard(
          mode: ThemeMode.system,
          label: 'system',
          isSelected: currentMode == ThemeMode.system,
          onTap: () => context.read<ThemeNotifier>().setMode(ThemeMode.system),
        ),
      ],
    );
  }
}

// MARK: THEME CARD

/// A tappable miniature UI preview representing one ThemeMode.
///
/// Colours are hardcoded to their respective theme values — these
/// are intentionally NOT reading from Theme.of(context), because
/// the card always shows its own theme regardless of the active one.
/// Light card always looks light, dark card always looks dark.
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.mode,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final ThemeMode mode;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? InktomeColors.white : InktomeColors.black;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // The preview card itself.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              // Slight scale-up when selected — subtle but tactile.
              transform: isSelected
                  ? (Matrix4.identity()
                      ..scaleByDouble(1.04, 1.04, 1.0, 1.0)
                      ..translateByDouble(-2.0, -2.0, 0.0, 1.0))
                  : Matrix4.identity(),
              child: DashedBorder(
                color: isSelected
                    ? labelColor
                    : labelColor.withValues(alpha: 0.0),
                radius: _cardRadius,
                child: SquircleClip(
                  radius: _cardRadius,
                  child: _CardPreview(mode: mode),
                ),
              ),
            ),
            const SizedBox(height: InktomeSpacing.sm),
            // Label below the card.
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: InktomeTextStyles.labelLarge.copyWith(
                color: labelColor.withValues(alpha: isSelected ? 1.0 : 0.45),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: CARD PREVIEW

/// The miniature UI inside each theme card.
///
/// Colours are hardcoded per-mode — see _ThemeCard for why.
/// For ThemeMode.system we show a split card: left half light, right half dark.
class _CardPreview extends StatelessWidget {
  const _CardPreview({required this.mode});

  final ThemeMode mode;

  // The two palette sets — pulled directly from InktomeColors.
  static const _light = _Palette(
    bg: InktomeColors.white,
    card: InktomeColors.cardOnWhite,
    fg: InktomeColors.black,
    muted: InktomeColors.greyMuted,
    dot: InktomeColors.black,
  );
  static const _dark = _Palette(
    bg: InktomeColors.black,
    card: InktomeColors.cardOnBlack,
    fg: InktomeColors.white,
    muted: InktomeColors.greyOnDark,
    dot: InktomeColors.white,
  );

  @override
  Widget build(BuildContext context) {
    if (mode == ThemeMode.system) {
      // Split preview: left = light, right = dark.
      return SizedBox(
        height: 110,
        child: Row(
          children: [
            Expanded(child: _SinglePreview(palette: _light, roundLeft: true)),
            Expanded(child: _SinglePreview(palette: _dark, roundRight: true)),
          ],
        ),
      );
    }

    final palette = mode == ThemeMode.light ? _light : _dark;
    return SizedBox(height: 110, child: _SinglePreview(palette: palette));
  }
}

// MARK: SINGLE PREVIEW

/// One half (or the full) themed miniature. Draws the dot grid,
/// two fake book covers, and a tiny nav pill at the bottom.
class _SinglePreview extends StatelessWidget {
  const _SinglePreview({
    required this.palette,
    this.roundLeft = false,
    this.roundRight = false,
  });

  final _Palette palette;
  final bool roundLeft;
  final bool roundRight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Only round the corners relevant to this half of the split card.
      borderRadius: BorderRadius.only(
        topLeft: roundLeft ? Radius.circular(_cardRadius) : Radius.zero,
        bottomLeft: roundLeft ? Radius.circular(_cardRadius) : Radius.zero,
        topRight: roundRight ? Radius.circular(_cardRadius) : Radius.zero,
        bottomRight: roundRight ? Radius.circular(_cardRadius) : Radius.zero,
      ),
      child: ColoredBox(
        color: palette.bg,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Two fake book cover rectangles, top area.
              Expanded(
                child: Row(
                  children: [
                    _FakeBook(color: palette.card),
                    const SizedBox(width: 6),
                    _FakeBook(color: palette.muted.withValues(alpha: 0.3)),
                  ],
                ),
              ),

              // Tiny nav pill at the bottom.
              Container(
                height: 14,
                decoration: ShapeDecoration(
                  color: palette.card,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 5,
                    decoration: ShapeDecoration(
                      color: palette.fg,
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: FAKE BOOK

class _FakeBook extends StatelessWidget {
  const _FakeBook({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// MARK: PALETTE DATA CLASS

class _Palette {
  const _Palette({
    required this.bg,
    required this.card,
    required this.fg,
    required this.muted,
    required this.dot,
  });

  final Color bg;
  final Color card;
  final Color fg;
  final Color muted;
  final Color dot;
}
