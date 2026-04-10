import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

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
    // final scaffoldColor = Theme.of(context).colorScheme.surface;
    final isDark = scaffoldColor.computeLuminance() < 0.5;
    final pillBg = isDark ? InktomeColors.black : InktomeColors.white;
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // MARK: Pill 1 — main nav
              Flexible(
                child: SizedBox(
                  height: InktomeSpacing.navBarPillHeight,
                  child: _MainPill(
                    tabs: tabs,
                    selectedIndex: selectedIndex,
                    onTabSelected: onTabSelected,
                    pillBg: pillBg,
                    pillFg: pillFg,
                    isDark: isDark,
                  ),
                ),
              ),

              // MARK: Pill 2 — contextual action
              // Consumer rebuilds only this part of the tree when the
              // notifier fires, leaving Pill 1 completely untouched.
              SizedBox(
                height: InktomeSpacing.navBarPillHeight,
                child: Consumer<NavBarNotifier>(
                  builder: (context, notifier, _) {
                    // Fade + slight rightward slide in/out.
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        // 1. Define the Slide: -0.15 moves it from right-to-left (inward)
                        final slideIn = Tween<Offset>(
                          begin: const Offset(
                            -0.25,
                            0,
                          ), // Start slightly to the right, slide left
                          end: Offset.zero,
                        ).animate(animation);

                        // 2. Define the Rotation: -0.25 is -90 degrees (adjust to taste)
                        final rotateIn = Tween<double>(
                          begin: -0.2, // Start tilted
                          end: 0, // End upright
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: slideIn,
                            child: RotationTransition(
                              turns: rotateIn,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: notifier.hasAction
                          ? _ActionPill(
                              // Key tells AnimatedSwitcher to re-animate
                              // when the icon changes (e.g. switching tabs).
                              key: ValueKey(notifier.action!.icon),
                              action: notifier.action!,
                              pillBg: pillBg,
                              pillFg: pillFg,
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: MAIN NAV PILL (Pill 1)
/// The left pill containing the tab labels.
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

    return DashedBorder(
      color: pillFg,
      radius: InktomeSpacing.radiusLg,
      child: SquircleClip(
        radius: InktomeSpacing.radiusLg,
        child: ColoredBox(
          color: pillBg,
          child: Padding(
            padding: const EdgeInsets.all(InktomeSpacing.sm),
            child: _SlidingTabRow(
              tabs: tabs,
              selectedIndex: selectedIndex,
              pillFg: pillFg,
              selectedPillBg: selectedPillBg,
              selectedPillFg: selectedPillFg,
              onTap: onTabSelected,
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: SLIDING TAB ROW
class _SlidingTabRow extends StatefulWidget {
  const _SlidingTabRow({
    required this.tabs,
    required this.selectedIndex,
    required this.pillFg,
    required this.selectedPillBg,
    required this.selectedPillFg,
    required this.onTap,
  });

  final List<NavTab> tabs;
  final int selectedIndex;
  final Color pillFg;
  final Color selectedPillBg;
  final Color selectedPillFg;
  final ValueChanged<int> onTap;

  @override
  State<_SlidingTabRow> createState() => _SlidingTabRowState();
}

// MARK: SLIDING TAB ROW STATE
class _SlidingTabRowState extends State<_SlidingTabRow> {
  // One GlobalKey per tab so we can measure each tab's RenderBox.
  late List<GlobalKey> _keys;

  // The indicator's current position and size — animated.
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;
  double _indicatorHeight = 0;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.tabs.length, (_) => GlobalKey());
    // Measure after first frame so RenderBoxes exist.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicator();
      // Re-measure after fonts settle on first launch.
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _updateIndicator();
      });
    });
  }

  @override
  void didUpdateWidget(_SlidingTabRow old) {
    super.didUpdateWidget(old);
    // Re-measure whenever the selected tab changes.
    if (old.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
    }
  }

  void _updateIndicator() {
    final key = _keys[widget.selectedIndex];
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    // Position relative to this widget's own RenderBox.
    final parentBox = context.findRenderObject() as RenderBox?;
    if (parentBox == null) return;

    final offset = box.localToGlobal(Offset.zero, ancestor: parentBox);

    setState(() {
      _indicatorLeft = offset.dx;
      _indicatorWidth = box.size.width;
      _indicatorHeight = box.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Invisible row — sets the Stack's natural size and
        // gives us RenderBoxes to measure via GlobalKeys.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.tabs.length; i++)
              _NavTabItem(
                key: _keys[i],
                label: widget.tabs[i].label,
                isSelected: i == widget.selectedIndex,
                pillFg: widget.pillFg,
                selectedPillBg:
                    Colors.transparent, // indicator drawn separately
                selectedPillFg: widget.selectedPillFg,
                onTap: () => widget.onTap(i),
              ),
          ],
        ),

        // MARK: Sliding indicator — animates position and size.
        if (_indicatorWidth > 0)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack, // springy
            left: _indicatorLeft,
            top: 0,
            width: _indicatorWidth,
            height: _indicatorHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: widget.selectedPillBg,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(InktomeSpacing.sm + 2),
                  ),
                ),
              ),
            ),
          ),

        // Visible text row on top — selected tab text uses selectedPillFg.
        // Rendered again so text sits above the indicator.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.tabs.length; i++)
              _NavTabItem(
                label: widget.tabs[i].label,
                isSelected: i == widget.selectedIndex,
                pillFg: widget.pillFg,
                selectedPillBg:
                    Colors.transparent, // indicator handles background
                selectedPillFg: widget.selectedPillFg,
                onTap: () => widget.onTap(i),
              ),
          ],
        ),
      ],
    );
  }
}

// MARK: INDIVIDUAL TAB ITEM
/// A single tappable label chip inside Pill 1.
class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    super.key,
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
            borderRadius: BorderRadius.circular(InktomeSpacing.sm + 2),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.xs,
          vertical: InktomeSpacing.sm,
        ),
        child: Text(
          label,
          style: InktomeTextStyles.button.copyWith(
            color: isSelected ? selectedPillFg : pillFg,
            fontWeight: FontWeight.w300,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// MARK: ACTION PILL (Pill 2)
/// The right pill — shows the current screen's contextual action.
///
/// Stretches to match Pill 1's height via [IntrinsicHeight] in the parent,
/// and since it holds a single square icon it naturally becomes a circle.
/// Uses the same dashed squircle border as Pill 1 for visual consistency.
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    super.key,
    required this.action,
    required this.pillBg,
    required this.pillFg,
  });

  final NavAction action;
  final Color pillBg;
  final Color pillFg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      behavior: HitTestBehavior.opaque,
      child: DashedBorder(
        color: pillFg,
        radius: InktomeSpacing.radiusPill, // large → will become a circle
        child: SquircleClip(
          radius: InktomeSpacing.radiusPill,
          child: ColoredBox(
            color: pillBg,
            child: Padding(
              padding: const EdgeInsets.all(InktomeSpacing.md),
              child: LucideAnimatedIcon(
                icon: action.icon,
                color: pillFg,
                size: 28,
                onTap: action.onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
