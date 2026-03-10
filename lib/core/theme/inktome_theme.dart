import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';

/// Inktome theme system for Flutter app.
///
/// Provides light and dark themes with modern brutalist design.
/// Uses pill shapes, underline inputs, and high contrast.
///
/// See also:
/// * [InktomeColors] for color definitions
/// * [InktomeSpacing] for layout and spacing
/// * [InktomeTextStyles] for typography
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   theme: inktomeLightTheme(),
///   darkTheme: inktomeDarkTheme(),
///   themeMode: ThemeMode.system,
/// )
/// ```

// ? THEME DATA

/// Light theme for Inktome app.
///
/// Modern brutalist design with:
/// - Pill-shaped buttons and chips
/// - Squircle input fields with subtle borders
/// - High contrast black/white palette
///
/// Use this for MaterialApp.theme property.
ThemeData inktomeLightTheme() {
  // The ColorScheme tells Material 3 widgets which colours to use
  // for which roles. Even if you never reference these roles
  // directly in your own widgets, Flutter's built-in components
  // do — so they need to be correct or things render oddly.
  const colorScheme = ColorScheme(
    brightness: Brightness.light,

    // primary = the main action colour.
    // In monochromatic mode this is simply black.
    // When you introduce richBlue later, swap it here and
    // every primary-reading widget updates automatically.
    primary: InktomeColors.black,
    onPrimary: InktomeColors.white, // text/icons on top of primary
    // secondary = currently mirrors primary.
    // A separate slot exists so you can differentiate later.
    secondary: InktomeColors.black,
    onSecondary: InktomeColors.white,

    // surface = the default background for sheets, dialogs, cards.
    // onSurface = text and icons that sit on top of surface.
    surface: InktomeColors.white,
    onSurface: InktomeColors.black,

    // surfaceContainerLowest = the scaffold (page) background.
    // This is the 'page' your content sits on.
    surfaceContainerLowest: InktomeColors.white,

    // onSurfaceVariant = muted/secondary text and inactive icons.
    // Used by Flutter internally for things like hint text,
    // inactive nav labels, placeholder content.
    onSurfaceVariant: InktomeColors.greyMuted,

    outline: InktomeColors.greyMid,
    outlineVariant: InktomeColors.greyLight,

    error: InktomeColors.brickEmber,
    onError: InktomeColors.pureWhite,
    errorContainer: InktomeColors.cardOnWhite,
    onErrorContainer: InktomeColors.brickEmber,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,

    // Page background.
    // On light screens this is InktomeColors.white.
    // Individual screens can override via Scaffold(backgroundColor:)
    // if they need the black background instead.
    scaffoldBackgroundColor: InktomeColors.white,

    // Text theme using custom fonts with theme-aware colors
    textTheme: TextTheme(
      displayLarge: InktomeTextStyles.displayLarge,
      displayMedium: InktomeTextStyles.display,
      displaySmall: InktomeTextStyles.headingLarge,
      headlineLarge: InktomeTextStyles.headingLarge,
      headlineMedium: InktomeTextStyles.headingMedium,
      headlineSmall: InktomeTextStyles.headingSmall,
      titleLarge: InktomeTextStyles.headingSmall,
      titleMedium: InktomeTextStyles.bodyLarge,
      titleSmall: InktomeTextStyles.body,
      bodyLarge: InktomeTextStyles.bodyLarge,
      bodyMedium: InktomeTextStyles.body,
      bodySmall: InktomeTextStyles.bodySmall,
      labelLarge: InktomeTextStyles.labelLarge,
      labelMedium: InktomeTextStyles.label,
      labelSmall: InktomeTextStyles.labelSmall,
    ),

    // ? APP BAR
    //
    // Transparent so it always matches whatever background the
    // current screen uses — no hardcoded colour here.
    // The status bar icons are dark on light backgrounds.
    // On screens with a black background, wrap your Scaffold
    // in an AnnotatedRegion<SystemUiOverlayStyle> to flip them:
    //
    //   AnnotatedRegion<SystemUiOverlayStyle>(
    //     value: SystemUiOverlayStyle.light, // white icons
    //     child: Scaffold(
    //       backgroundColor: InktomeColors.black,
    //       ...
    //     ),
    //   )
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: InktomeColors.black,
      elevation: 0,
      scrolledUnderElevation: 0, // no shadow when content scrolls under
      centerTitle: false,
      titleTextStyle: InktomeTextStyles.headingSmall,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // dark icons on light bg
      ),
    ),

    // ? FILLED BUTTON
    //
    // The primary action on any screen.
    // Black background, white Londrina Solid label.
    // Use at most once per screen as the dominant action.
    //
    // Usage:
    //   FilledButton(
    //     onPressed: () {},
    //     child: const Text('add book'),
    //   )
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: InktomeColors.black,
        foregroundColor: InktomeColors.white,
        textStyle: InktomeTextStyles.button,
        minimumSize: const Size(0, 48), // 48sp minimum tap target height
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

    // ? OUTLINED BUTTON
    //
    // Secondary action — sits alongside a filled button or alone
    // when the action has moderate emphasis.
    // Transparent background, 2pt black stroke.
    //
    // Usage:
    //   OutlinedButton(
    //     onPressed: () {},
    //     child: const Text('cancel'),
    //   )
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

    // ? TEXT BUTTON
    //
    // Low-emphasis action — no container, no border.
    // Use for things like 'skip', 'learn more', 'undo'.
    // Never for destructive actions (those should be outlined
    // or have an explicit warning state).
    //
    // Will switch to richBlue foreground when accent is introduced.
    //
    // Usage:
    //   TextButton(
    //     onPressed: () {},
    //     child: const Text('skip for now'),
    //   )
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

    // ? INPUT DECORATION
    //
    // Used by TextField and TextFormField.
    // Filled background matches card surface for hierarchy.
    // Subtle squircle shape with full border.
    // Border color changes on focus and error.
    //
    // If a specific input needs different styling (e.g. a search
    // bar with different background), override InputDecoration
    // directly on that widget rather than changing this default.
    //
    // Usage:
    //   TextField(
    //     decoration: InputDecoration(
    //       hintText: 'Search your library',
    //     ),
    //   )
    inputDecorationTheme: InputDecorationTheme(
      filled: true, // filled background to match surface
      fillColor: InktomeColors.cardOnWhite, // matches light theme surface
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: InktomeSpacing.md,
        vertical: InktomeSpacing.md,
      ),
      // Default border (not focused, no error)
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
      labelStyle: InktomeTextStyles.labelLarge,
      errorStyle: InktomeTextStyles.labelLargeWithColor(
        InktomeColors.brickEmber,
      ),
    ),

    // ? CARD
    //
    // Cards sit on top of the scaffold background.
    // Use for content containers, dialogs, sheets.
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0, // flat design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
      ),
    ),
  );
}

/// Dark theme for Inktome app.
///
/// Inverts the light theme with white backgrounds and black text.
/// Maintains the same brutalist design language.
///
/// Use this for MaterialApp.darkTheme property.
ThemeData inktomeDarkTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.dark,

    primary: InktomeColors.white,
    onPrimary: InktomeColors.black,

    secondary: InktomeColors.white,
    onSecondary: InktomeColors.black,

    surface: InktomeColors.cardOnBlack,
    onSurface: InktomeColors.white,

    surfaceContainerLowest: InktomeColors.black,
    onSurfaceVariant: InktomeColors.greyOnDark,

    outline: InktomeColors.greyDark,
    outlineVariant: InktomeColors.greyDarker,

    error: InktomeColors.brickEmber,
    onError: InktomeColors.pureBlack,
    errorContainer: InktomeColors.brickEmber,
    onErrorContainer: InktomeColors.pureWhite,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,

    scaffoldBackgroundColor: InktomeColors.black,

    textTheme: TextTheme(
      displayLarge: InktomeTextStyles.displayLarge,
      displayMedium: InktomeTextStyles.display,
      displaySmall: InktomeTextStyles.headingLarge,
      headlineLarge: InktomeTextStyles.headingLarge,
      headlineMedium: InktomeTextStyles.headingMedium,
      headlineSmall: InktomeTextStyles.headingSmall,
      titleLarge: InktomeTextStyles.headingSmall,
      titleMedium: InktomeTextStyles.bodyLarge,
      titleSmall: InktomeTextStyles.body,
      bodyLarge: InktomeTextStyles.bodyLarge,
      bodyMedium: InktomeTextStyles.body,
      bodySmall: InktomeTextStyles.bodySmall,
      labelLarge: InktomeTextStyles.labelLarge,
      labelMedium: InktomeTextStyles.label,
      labelSmall: InktomeTextStyles.labelSmall,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: InktomeColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: InktomeTextStyles.headingSmallWithColor(
        InktomeColors.white,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // white icons on dark bg
      ),
    ),

    // Filled button flips — white background, black label
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

    // Outlined button flips — white stroke, white label
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

    inputDecorationTheme: InputDecorationTheme(
      filled: true, // filled background to match surface
      fillColor: InktomeColors.cardOnBlack, // matches dark theme surface
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

    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0, // flat design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(InktomeSpacing.radiusMd),
      ),
    ),
  );
}
