/// Inktome ThemeData definitions — light and dark.
///
/// Both themes share identical component structure.
/// Only colours differ, sourced from [lightColorScheme] and
/// [darkColorScheme] in `inktome_color_schemes.dart`.
///
/// See also:
/// * [InktomeColors] for all hex colour definitions
/// * [InktomeSpacing] for layout dimensions and font sizes
/// * [InktomeTextStyles] for typography shape definitions
/// * `inktome_color_schemes.dart` for the raw ColorScheme data
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   theme: inktomeLightTheme(),
///   darkTheme: inktomeDarkTheme(),
///   themeMode: ThemeMode.system,
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inktome/core/theme/inktome_color_schemes.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';

// ? MARK: LIGHT THEME

/// Light theme for Inktome.
///
/// Scaffold background: [InktomeColors.white].
/// Primary text: [InktomeColors.black].
/// Muted text: [InktomeColors.greyMuted].
ThemeData inktomeLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,

    // The page background behind all content.
    scaffoldBackgroundColor: InktomeColors.white,

    // ? MARK: Text theme
    //
    // InktomeTextStyles defines SHAPE only — font family, size,
    // weight, letter spacing, line height. No colour lives there.
    //
    // Colour is applied here, once per theme, using the WithColor
    // factory methods. Any widget that reads from
    // Theme.of(context).textTheme automatically gets the correct
    // colour for the current mode — no manual passing required.
    //
    // Rule: always read from Theme.of(context).textTheme in widgets.
    // Never call InktomeTextStyles directly in a build method —
    // that bypasses this colour layer entirely.
    textTheme: TextTheme(
      displayLarge: InktomeTextStyles.displayLargeWithColor(
        InktomeColors.black,
      ),
      displayMedium: InktomeTextStyles.displayWithColor(InktomeColors.black),
      displaySmall: InktomeTextStyles.headingLargeWithColor(
        InktomeColors.black,
      ),
      headlineLarge: InktomeTextStyles.headingLargeWithColor(
        InktomeColors.black,
      ),
      headlineMedium: InktomeTextStyles.headingMediumWithColor(
        InktomeColors.black,
      ),
      headlineSmall: InktomeTextStyles.headingSmallWithColor(
        InktomeColors.black,
      ),
      titleLarge: InktomeTextStyles.headingSmallWithColor(InktomeColors.black),
      titleMedium: InktomeTextStyles.bodyLargeWithColor(InktomeColors.black),
      titleSmall: InktomeTextStyles.bodyWithColor(InktomeColors.black),
      bodyLarge: InktomeTextStyles.bodyLargeWithColor(InktomeColors.black),
      bodyMedium: InktomeTextStyles.bodyWithColor(InktomeColors.black),
      bodySmall: InktomeTextStyles.bodySmallWithColor(InktomeColors.black),
      // Labels use greyMuted rather than black — they are UI chrome, not content. Chips, nav labels, captions should recede.
      labelLarge: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.greyMuted,
      ),
      labelMedium: InktomeTextStyles.labelWithColor(InktomeColors.greyMuted),
      labelSmall: InktomeTextStyles.labelSmallWithColor(
        InktomeColors.greyMuted,
      ),
    ),

    // ? MARK: App bar
    appBarTheme: AppBarTheme(
      // Transparent background so the AppBar blends into whatever screen background sits behind it.
      backgroundColor: Colors.transparent,
      // foregroundColor covers the back-chevron, action icons, and any Text widget inside the AppBar that has no explicit style.
      foregroundColor: InktomeColors.black,
      elevation: 0,
      // Material 3 by default adds a surface tint and shadow when content scrolls under the app bar. Setting this to 0 disables that behaviour, keeping the bar visually flat and part of the same surface as the scaffold.
      scrolledUnderElevation: 0,
      centerTitle: false,
      // IMPORTANT: AppBar does NOT inherit from the TextTheme for its title. It reads this property directly. If this style has no colour, the title falls back to AppBar's internal DefaultTextStyle which is always white — regardless of theme. Always set an explicit colour here.
      titleTextStyle: InktomeTextStyles.headingLargeWithColor(
        InktomeColors.black,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // dark icons on light bg
      ),
    ),

    // ? MARK: Filled button
    // Usage:
    //   FilledButton(onPressed: () {}, child: const Text('add book'))
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: InktomeColors.black,
        foregroundColor: InktomeColors.white,
        textStyle: InktomeTextStyles.buttonWithColor(InktomeColors.white),
        // minimumSize: 48sp height satisfies Material touch target guidelines. Width is 0 so the button shrinks to fit its label.
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.lg,
          vertical: InktomeSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(InktomeSpacing.radiusPill),
          ),
        ),
      ),
    ),

    // ? MARK: Outlined button
    // Usage:
    //   OutlinedButton(onPressed: () {}, child: const Text('cancel'))
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: InktomeColors.black,
        textStyle: InktomeTextStyles.buttonWithColor(InktomeColors.black),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.lg,
          vertical: InktomeSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(InktomeSpacing.radiusPill),
          ),
        ),
      ),
    ),

    // ? MARK: Text button
    // Low-emphasis action — no container, no border.
    // Use for things like 'skip', 'learn more', 'undo'.
    // Never for destructive actions (use outlined with a warning state).
    //
    // Usage:
    //   TextButton(onPressed: () {}, child: const Text('skip for now'))
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: InktomeColors.black,
        textStyle: InktomeTextStyles.buttonWithColor(InktomeColors.black),
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.sm,
          vertical: InktomeSpacing.xs,
        ),
      ),
    ),

    // ? MARK: Input decoration
    // Used by TextField and TextFormField automatically.
    //
    // If a specific input needs different styling (e.g. a borderless
    // search bar), override InputDecoration directly on that widget
    // rather than changing this default.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: InktomeColors.cardOnWhite,
      // Preserves comfortable vertical padding inside the field. Set to true only if you need compact form rows.
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: InktomeSpacing.md,
        vertical: InktomeSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(color: InktomeColors.greyMid, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(color: InktomeColors.greyMid, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(color: InktomeColors.black, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(
          color: InktomeColors.brickEmber,
          width: 2.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(
          color: InktomeColors.brickEmber,
          width: 2.0,
        ),
      ),
      hintStyle: InktomeTextStyles.bodyWithColor(InktomeColors.greyMuted),
      labelStyle: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.greyMuted,
      ),
      errorStyle: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.brickEmber,
      ),
    ),

    // ? MARK: CHIP
    //
    // backgroundColor: transparent — unselected chips show no fill,
    // just the border stroke defined in side.
    //
    // selectedColor: black — when a FilterChip or ChoiceChip is
    // selected in light mode, it fills with black and the label
    // switches to white via secondaryLabelStyle, maintaining contrast.
    //
    // labelStyle — text colour for unselected chips (black on transparent).
    // secondaryLabelStyle — text colour when selected (white on black).
    //
    // side: greyMid border — same border colour as idle input fields,
    // keeping the visual language consistent across interactive elements.
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: InktomeColors.black,
      labelStyle: InktomeTextStyles.labelLargeWithColor(InktomeColors.black),
      secondaryLabelStyle: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.white,
      ),
      side: const BorderSide(color: InktomeColors.greyMid, width: 1.0),
      padding: const EdgeInsets.symmetric(
        horizontal: InktomeSpacing.sm,
        vertical: InktomeSpacing.xs,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(InktomeSpacing.radiusPill),
        ),
      ),
    ),

    // ? MARK: CARD
    //
    // Cards sit one layer above the scaffold.
    // color: colorScheme.surface — reads from the ColorScheme so
    // it automatically updates if you ever change the surface colour.
    //
    // Shape hierarchy is communicated by colour contrast alone,
    // not by shadow depth.
    //
    // shape: radiusMd — softer than a pill, appropriate for content
    // containers that hold text and images rather than single actions.
    cardTheme: CardThemeData(
      color: lightColorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
      ),
    ),
  );
}

// ? MARK: DARK THEME

/// Dark theme for Inktome.
///
/// Scaffold background: [InktomeColors.black].
/// Primary text: [InktomeColors.white].
/// Muted text: [InktomeColors.greyOnDark].
///
/// Structure mirrors the light theme exactly.
/// Only colours change — no layout or shape differences.
ThemeData inktomeDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: InktomeColors.black,

    // ? MARK: Text theme (dark)
    //
    // Identical slot mapping to light theme.
    // Primary text flips to white. Labels use greyOnDark —
    // a lighter grey calibrated for legibility on dark backgrounds.
    textTheme: TextTheme(
      displayLarge: InktomeTextStyles.displayLargeWithColor(
        InktomeColors.white,
      ),
      displayMedium: InktomeTextStyles.displayWithColor(InktomeColors.white),
      displaySmall: InktomeTextStyles.headingLargeWithColor(
        InktomeColors.white,
      ),
      headlineLarge: InktomeTextStyles.headingLargeWithColor(
        InktomeColors.white,
      ),
      headlineMedium: InktomeTextStyles.headingMediumWithColor(
        InktomeColors.white,
      ),
      headlineSmall: InktomeTextStyles.headingSmallWithColor(
        InktomeColors.white,
      ),
      titleLarge: InktomeTextStyles.headingSmallWithColor(InktomeColors.white),
      titleMedium: InktomeTextStyles.bodyLargeWithColor(InktomeColors.white),
      titleSmall: InktomeTextStyles.bodyWithColor(InktomeColors.white),
      bodyLarge: InktomeTextStyles.bodyLargeWithColor(InktomeColors.white),
      bodyMedium: InktomeTextStyles.bodyWithColor(InktomeColors.white),
      bodySmall: InktomeTextStyles.bodySmallWithColor(InktomeColors.white),
      labelLarge: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.greyOnDark,
      ),
      labelMedium: InktomeTextStyles.labelWithColor(InktomeColors.greyOnDark),
      labelSmall: InktomeTextStyles.labelSmallWithColor(
        InktomeColors.greyOnDark,
      ),
    ),

    // ? MARK: App bar (dark)
    // statusBarIconBrightness flips to Brightness.light — renders white status bar icons, legible against dark scaffold.
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: InktomeColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: InktomeTextStyles.headingLargeWithColor(
        InktomeColors.white,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // white icons on dark bg
      ),
    ),

    // ? MARK: Filled button (dark)
    // Flips from light — white background, black label.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: InktomeColors.white,
        foregroundColor: InktomeColors.black,
        textStyle: InktomeTextStyles.buttonWithColor(InktomeColors.black),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.lg,
          vertical: InktomeSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(InktomeSpacing.radiusPill),
          ),
        ),
      ),
    ),

    // ? MARK: Outlined button (dark)
    // White stroke, white label — transparent background preserved.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: InktomeColors.white,
        textStyle: InktomeTextStyles.buttonWithColor(InktomeColors.white),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.lg,
          vertical: InktomeSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(InktomeSpacing.radiusPill),
          ),
        ),
      ),
    ),

    // MARK: Text button (dark)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: InktomeColors.white,
        textStyle: InktomeTextStyles.buttonWithColor(InktomeColors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.sm,
          vertical: InktomeSpacing.xs,
        ),
      ),
    ),

    // ? MARK: Input decoration (dark)
    // fillColor flips to cardOnBlack — one step lighter than the black scaffold, same visual logic as cardOnWhite in light mode.
    // Focus border stays white for maximum contrast on dark bg.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: InktomeColors.cardOnBlack,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: InktomeSpacing.md,
        vertical: InktomeSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(color: InktomeColors.greyDark, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(color: InktomeColors.greyDark, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(color: InktomeColors.white, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(
          color: InktomeColors.brickEmber,
          width: 2.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
        borderSide: const BorderSide(
          color: InktomeColors.brickEmber,
          width: 2.0,
        ),
      ),
      hintStyle: InktomeTextStyles.bodyWithColor(InktomeColors.greyOnDark),
      labelStyle: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.greyOnDark,
      ),
      errorStyle: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.brickEmber,
      ),
    ),

    // ? MARK: CHIP
    // backgroundColor: transparent — unselected chips show no fill.
    //
    // selectedColor: white — selected chip fills with white, label
    // switches to black via secondaryLabelStyle. Mirrors the light
    // theme logic but inverted — selected always fills with the
    // primary colour (black in light, white in dark).
    //
    // side: greyDark border — matches idle input field borders
    // in dark mode, keeping the visual language consistent.
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: InktomeColors.white,
      labelStyle: InktomeTextStyles.labelLargeWithColor(InktomeColors.white),
      secondaryLabelStyle: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.black,
      ),
      side: const BorderSide(color: InktomeColors.greyDark, width: 1.0),
      padding: const EdgeInsets.symmetric(
        horizontal: InktomeSpacing.sm,
        vertical: InktomeSpacing.xs,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(InktomeSpacing.radiusPill),
        ),
      ),
    ),

    // ? MARK: CARD
    // color reads from darkColorScheme.surface — which is cardOnBlack.
    // Same elevation and shape as light.
    cardTheme: CardThemeData(
      color: darkColorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
      ),
    ),
  );
}
