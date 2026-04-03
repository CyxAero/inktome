import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';

// Reusable search input used by both the overlay and the search page.
// Accepts title, author, or ISBN — keyboardType is text, not number.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.animation,
    required this.focusNode,
    required this.controller,
    required this.inputBg,
    required this.textColor,
    required this.labelColor,
    required this.inputSubmitBg,
    required this.inputSubmitTextColor,
    required this.onSubmit,
    this.autofocus = false,
  });

  // Optional — overlay animates it in, search page doesn't need to.
  final Animation<double>? animation;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Color inputBg;
  final Color textColor;
  final Color labelColor;
  final Color inputSubmitBg;
  final Color inputSubmitTextColor;
  final ValueChanged<String> onSubmit;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final field = DashedBorder(
      color: textColor,
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
              autofocus: autofocus,
              // Text — accepts titles, authors, and ISBNs.
              keyboardType: TextInputType.text,
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
                  horizontal: InktomeSpacing.xs,
                  vertical: InktomeSpacing.md,
                ),
                hintText: 'title, author or isbn',
                hintStyle: InktomeTextStyles.buttonWithColor(
                  labelColor,
                ).copyWith(fontSize: 18),
                suffixIcon: GestureDetector(
                  onTap: () => onSubmit(controller.text),
                  child: SizedBox(
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
    );

    // If no animation is provided, render the field directly.
    if (animation == null) return field;

    // Overlay version — slides up and fades in on enter.
    return AnimatedBuilder(
      animation: animation!,
      builder: (context, child) => Opacity(
        opacity: animation!.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - animation!.value)),
          child: child,
        ),
      ),
      child: field,
    );
  }
}
