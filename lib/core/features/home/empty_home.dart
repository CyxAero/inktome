import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';

// MARK: EmptyHome
//
// Shown when the user has no books yet.
// Friendly prompt to add their first book — tapping the message
// triggers the same add-book overlay as the nav bar + button.
class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: InktomeSpacing.pagePadding,
      ),
      child: Column(
        children: [
          const Spacer(),

          // Empty state prompt — centred in the remaining space
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dashed squircle placeholder — tappable, opens add overlay
                // GestureDetector(
                //   onTap: () => showAddBookOverlay(context),
                //   child: DashedBorder(
                //     color: mutedColor,
                //     radius: 24,
                //     child: SquircleClip(
                //       radius: 20,
                //       child: SizedBox(
                //         width: 180,
                //         height: 270,
                //         child: ColoredBox(
                //           color: isDark
                //               ? InktomeColors.cardOnBlack
                //               : InktomeColors.cardOnWhite,
                //           child: Center(
                //             child: Icon(Icons.add, color: mutedColor, size: 40),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: InktomeSpacing.lg),
                //
                // Text(
                //   'add your first book',
                //   style: InktomeTextStyles.headingSmall.copyWith(
                //     color: mutedColor,
                //   ),
                // ),
                SvgPicture.asset(
                  'assets/images/OOPS!.svg',
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                Text(
                  'IT SEEMS YOUR\nDATABASE IS EMPTY',
                  textAlign: TextAlign.center,
                  style: InktomeTextStyles.headingSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 42,
                    height: 0.8,
                  ),
                ),
                const SizedBox(height: InktomeSpacing.sm),
                Text(
                  'why don\'t you start by adding\na book to your '
                  'library?',
                  textAlign: TextAlign.center,
                  style: InktomeTextStyles.body.copyWith(
                    fontSize: 28,
                    height: 1,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(35, 0), // Move right by 30 pixels
                  child: Transform.rotate(
                    // Rotate ~8.6 degrees anti-clockwise(positive is clockwise)
                    angle: -0.15,
                    child: SvgPicture.asset(
                      'assets/images/Arrow.svg',
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
