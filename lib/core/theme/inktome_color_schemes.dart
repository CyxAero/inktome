/// Material 3 ColorScheme definitions for Inktome.
///
/// These are pure data constants — no ThemeData logic lives here.
/// Both are consumed by [inktomeLightTheme] and [inktomeDarkTheme]
/// in `inktome_theme.dart`, and can also be referenced directly
/// anywhere you need the raw scheme (e.g. custom painters, tests).
///
/// Naming convention: every 'on' colour is what sits ON TOP of
/// its paired colour. [ColorScheme.onPrimary] is text/icons on a
/// primary-coloured surface. [ColorScheme.onSurface] is text/icons
/// on a card, sheet, or scaffold.
///
/// See also:
/// * [InktomeColors] for all hex colour definitions
/// * `inktome_theme.dart` for the full ThemeData build

import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_colors.dart';


// ? MARK: LIGHT COLOUR SCHEME

/// ColorScheme for [inktomeLightTheme].
///
/// Scaffold background: [InktomeColors.white].
/// Primary action colour: [InktomeColors.black].
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // primary = the main interactive/action colour.
  // Monochromatic for now — black in light mode.
  // When richBlue is introduced, swap it here once and every
  // primary-reading widget (FilledButton, Switch, Slider, etc.)
  // updates automatically.
  primary: InktomeColors.black,
  onPrimary: InktomeColors.white, // text/icons on a filled primary surface
  // secondary = currently mirrors primary.
  // Kept as a separate slot so you can diverge later without
  // touching primary (e.g. a tonal chip colour).
  secondary: InktomeColors.black,
  onSecondary: InktomeColors.white,

  // surface = default background for cards, sheets, and dialogs.
  // onSurface = text and icons that sit on top of surface.
  // Flutter uses onSurface for body text in many built-in widgets.
  surface: InktomeColors.white,
  onSurface: InktomeColors.black,

  // surfaceContainerLowest = the very bottom layer — the scaffold.
  // Think of it as the 'page' everything else sits on.
  surfaceContainerLowest: InktomeColors.white,

  // onSurfaceVariant = secondary/muted text and inactive icons.
  // Flutter reads this for hint text, inactive nav labels,
  // unselected tab icons, and placeholder content automatically.
  onSurfaceVariant: InktomeColors.greyMuted,

  // outline = default border colour for inputs, dividers, chips.
  // outlineVariant = the subtler version — used for decorative
  // dividers that shouldn't compete with interactive borders.
  outline: InktomeColors.greyMid,
  outlineVariant: InktomeColors.greyLight,

  // error = destructive actions and validation failures.
  // onError = text/icons on top of an error-coloured surface.
  // errorContainer = a softer error background (e.g. an error banner).
  // onErrorContainer = text on top of errorContainer.
  error: InktomeColors.brickEmber,
  onError: InktomeColors.pureWhite,
  errorContainer: InktomeColors.cardOnWhite,
  onErrorContainer: InktomeColors.brickEmber,
);

// ? MARK: DARK COLOUR SCHEME

/// ColorScheme for [inktomeDarkTheme].
///
/// Scaffold background: [InktomeColors.black].
/// Primary action colour: [InktomeColors.white].
///
/// The dark scheme is not a simple inversion of light.
/// [ColorScheme.surface] uses [InktomeColors.cardOnBlack] rather
/// than pure black — cards and sheets sit one step lighter than
/// the scaffold, maintaining the same visual hierarchy logic as
/// light mode (where cards are [InktomeColors.cardOnWhite],
/// slightly darker than the scaffold).
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: InktomeColors.white, // flipped — white is now the action colour
  onPrimary: InktomeColors.black,

  secondary: InktomeColors.white,
  onSecondary: InktomeColors.black,

  // surface = cardOnBlack, not pure black.
  // One step lighter than the scaffold — mirrors the light theme
  // logic where cards are one step darker than the scaffold.
  surface: InktomeColors.cardOnBlack,
  onSurface: InktomeColors.white,

  surfaceContainerLowest: InktomeColors.black, // the scaffold itself
  onSurfaceVariant: InktomeColors.greyOnDark, // muted text on dark bg

  outline: InktomeColors.greyDark,
  outlineVariant: InktomeColors.greyDarker,

  error: InktomeColors.brickEmber,
  onError: InktomeColors.pureBlack,
  errorContainer: InktomeColors.brickEmber,
  onErrorContainer: InktomeColors.pureWhite,
);