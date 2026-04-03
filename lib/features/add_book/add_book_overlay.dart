import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

// MARK: PUBLIC API

void showAddBookOverlay(BuildContext context) {
  context.read<NavBarNotifier>().showOverlay(
    closeAction: () => _overlayContentKey.currentState?.dismiss(),
  );
}

void dismissAddBookOverlay() {
  _overlayContentKey.currentState?.dismiss();
}

// Private — only this file needs to reach the state directly.
final GlobalKey<AddBookOverlayContentState> _overlayContentKey =
    GlobalKey<AddBookOverlayContentState>();

// MARK: OVERLAY CONTENT

/// Full-screen overlay, rendered as layer 3 in AppShell's Stack (above the nav bar).
///
/// Two states:
///   Default — options visible, ISBN field resting above the nav bar.
///   Keyboard open — options fade out, ISBN field rises to sit above keyboard.
///
/// Tapping the dim area while keyboard is open just closes the keyboard (restoring
/// the default state). Tapping while keyboard is closed dismisses the overlay.
/// The system back gesture follows the same two-step logic via PopScope in AppShell.
class AddBookOverlayContent extends StatefulWidget {
  AddBookOverlayContent() : super(key: _overlayContentKey);

  @override
  State<AddBookOverlayContent> createState() => AddBookOverlayContentState();
}

class AddBookOverlayContentState extends State<AddBookOverlayContent>
    with TickerProviderStateMixin {
  // MARK: CONTROLLERS

  late final AnimationController _bgController; // blur + dim
  late final AnimationController _itemsController; // stagger-in for options
  late final AnimationController
  _isbnController; // ISBN field slide-up on enter

  late final Animation<double> _dimOpacity;
  late final Animation<double> _blurSigma;

  bool _dismissing = false;

  final _isbnFocusNode = FocusNode();
  final _isbnTextController = TextEditingController();

  static const _options = [
    _OverlayOption(label: 'online search', icon: search),
    _OverlayOption(label: 'barcode scan', icon: scan_text),
    _OverlayOption(label: 'manual input', icon: file_pen_line),
  ];

  // MARK: LIFECYCLE

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _itemsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _isbnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _dimOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOut));
    _blurSigma = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOut));

    // Stagger the enter sequence so the blur lands first, then content.
    _bgController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _itemsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _isbnController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _itemsController.dispose();
    _isbnController.dispose();
    _isbnFocusNode.dispose();
    _isbnTextController.dispose();
    super.dispose();
  }

  // MARK: DISMISS

  void dismiss() {
    if (_dismissing) return;
    setState(() => _dismissing = true);

    // Close keyboard silently before reversing — no listener to worry about
    // since we're not using a focus listener anywhere in this file.
    _isbnFocusNode.unfocus();
    _isbnController.reverse();
    _itemsController.reverse();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _bgController.reverse().whenComplete(() {
        if (!mounted) return;
        context.read<NavBarNotifier>().hideOverlay();
      });
    });
  }

  // MARK: STAGGER HELPER

  Animation<double> _itemAnimation(int index) {
    const staggerMs = 90;
    const itemDurationMs = 300;
    final totalMs = _itemsController.duration!.inMilliseconds;
    final start = (staggerMs * index) / totalMs;
    final end = (staggerMs * index + itemDurationMs) / totalMs;

    return CurvedAnimation(
      parent: _itemsController,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOutBack,
      ),
    );
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final labelColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;
    final inputBg = isDark
        ? InktomeColors.cardOnBlack
        : InktomeColors.cardOnWhite;
    final inputSubmitBg = isDark ? InktomeColors.white : InktomeColors.black;
    final inputSubmitTextColor = isDark
        ? InktomeColors.black
        : InktomeColors.white;

    final size = MediaQuery.sizeOf(context);

    // viewInsets.bottom is the ground truth for how much the keyboard
    // has pushed up. We derive everything from this rather than tracking
    // focus ourselves — it updates every frame as the keyboard animates,
    // so layout always reflects physical reality.
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = keyboardHeight > 50;

    final isbnBottomOffset = keyboardOpen
        ? keyboardHeight + InktomeSpacing.md
        : InktomeSpacing.navBarPillHeight + InktomeSpacing.lg * 2;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Two-step dismiss: first tap closes the keyboard if it's open,
        // second tap (or back gesture) closes the overlay.
        onTap: keyboardOpen ? _isbnFocusNode.unfocus : dismiss,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _blurSigma.value,
                sigmaY: _blurSigma.value,
              ),
              child: ColoredBox(
                color: (isDark ? InktomeColors.black : InktomeColors.white)
                    .withValues(alpha: _dimOpacity.value * 0.72),
                child: child,
              ),
            );
          },
          // child slot keeps the Stack out of the blur/dim rebuild cycle —
          // AnimatedBuilder only repaints the BackdropFilter + ColoredBox.
          child: Stack(
            children: [
              // MARK: OPTIONS
              // Fixed position — 42% down the screen on any device.
              // AnimatedOpacity driven directly by keyboardOpen, so the fade
              // is always in sync with the keyboard's physical position.
              // No controller, no listener, no setState needed here.
              Positioned(
                top: size.height * 0.42,
                left: InktomeSpacing.pagePadding,
                right: InktomeSpacing.pagePadding,
                child: AnimatedOpacity(
                  opacity: keyboardOpen ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: IgnorePointer(
                    // Absorb taps while invisible so they fall through to
                    // the dismiss gesture on the outer GestureDetector.
                    ignoring: keyboardOpen,
                    child: GestureDetector(
                      onTap: () {}, // Prevent options taps reaching dismiss.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 0; i < _options.length; i++)
                            _StaggeredOptionLabel(
                              option: _options[i],
                              animation: _itemAnimation(i),
                              textColor: textColor,
                              screenSize: size,
                              onTap: () => _onOptionTapped(_options[i].label),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // MARK: ISBN FIELD
              // AnimatedPositioned chases keyboardHeight each frame.
              // Duration is slightly longer than the keyboard animation (~250ms)
              // so the field trails the keyboard naturally rather than snapping.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: InktomeSpacing.pagePadding,
                right: InktomeSpacing.pagePadding,
                bottom: isbnBottomOffset,
                child: GestureDetector(
                  onTap: () {}, // Prevent field taps reaching dismiss.
                  child: _IsbnField(
                    animation: CurvedAnimation(
                      parent: _isbnController,
                      curve: Curves.easeOutBack,
                    ),
                    focusNode: _isbnFocusNode,
                    controller: _isbnTextController,
                    inputBg: inputBg,
                    textColor: textColor,
                    labelColor: labelColor,
                    inputSubmitBg: inputSubmitBg,
                    inputSubmitTextColor: inputSubmitTextColor,
                    onSubmit: _onIsbnSubmitted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: CALLBACKS

  // MARK: onOptionTapped
  void _onOptionTapped(String label) {
    // Don't dismiss the overlay — push the route on top of it.
    // When the user closes the route, they land back here naturally.
    // The overlay only dismisses once a book is actually saved, or
    // when the user explicitly closes it with ×.
    switch (label) {
      case 'online search':
        context.push('/search');
      case 'barcode scan':
        // TODO: launch barcode scanner, then push('/search?q=ISBN').
        break;
      case 'manual input':
        // TODO: push('/book/new').
        break;
    }
  }

  // MARK: onIsbnSubmitted
  void _onIsbnSubmitted(String isbn) {
    // TODO: push online-search pre-filled with ISBN.
    debugPrint('AddBook: ISBN submitted $isbn');
  }
}

// MARK: STAGGERED OPTION LABEL

class _StaggeredOptionLabel extends StatelessWidget {
  const _StaggeredOptionLabel({
    required this.option,
    required this.animation,
    required this.textColor,
    required this.screenSize,
    required this.onTap,
  });

  final _OverlayOption option;
  final Animation<double> animation;
  final Color textColor;
  final Size screenSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(24 * (1 - animation.value), 0),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.008),
          child: Text(
            option.label,
            textAlign: TextAlign.right,
            style: InktomeTextStyles.headingMediumWithColor(
              textColor,
            ).copyWith(fontSize: screenSize.width * 0.10),
          ),
        ),
      ),
    );
  }
}

// MARK: ISBN FIELD

class _IsbnField extends StatelessWidget {
  const _IsbnField({
    required this.animation,
    required this.focusNode,
    required this.controller,
    required this.inputBg,
    required this.textColor,
    required this.labelColor,
    required this.inputSubmitBg,
    required this.inputSubmitTextColor,
    required this.onSubmit,
  });

  final Animation<double> animation;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Color inputBg;
  final Color textColor;
  final Color labelColor;
  final Color inputSubmitBg;
  final Color inputSubmitTextColor;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: InktomeSpacing.xs),
            child: Text(
              'DO YOU KNOW THE ISBN?',
              style: InktomeTextStyles.buttonWithColor(
                labelColor,
              ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w900),
            ),
          ),
          DashedBorder(
            color: labelColor,
            radius: InktomeSpacing.radiusLg,
            child: SquircleClip(
              radius: InktomeSpacing.radiusLg,
              child: ColoredBox(
                color: inputBg,
                child: Padding(
                  padding: const EdgeInsets.all(InktomeSpacing.sm),
                  child: TextField(
                    focusNode: focusNode,
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSubmit,
                    style: InktomeTextStyles.buttonWithColor(
                      textColor,
                    ).copyWith(fontSize: 18),
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: InktomeSpacing.md,
                        vertical: InktomeSpacing.md,
                      ),
                      hintText: 'enter isbn',
                      hintStyle: InktomeTextStyles.buttonWithColor(
                        labelColor,
                      ).copyWith(fontSize: 18),
                      suffixIcon: SizedBox(
                        width: 48,
                        height: 48,
                        child: SquircleClip(
                          radius: InktomeSpacing.radiusMd,
                          child: ColoredBox(
                            color: inputSubmitBg,
                            child: Center(
                              child: IgnorePointer(
                                child: LucideAnimatedIcon(
                                  icon: arrow_right,
                                  color: inputSubmitTextColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
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
}

// MARK: OPTION DATA CLASS

class _OverlayOption {
  const _OverlayOption({required this.label, required this.icon});
  final String label;
  final LucideAnimatedIconData icon;
}
