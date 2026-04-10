import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';

/// Typography scale for Inktome.
///
/// **Text Style Hierarchy:**
/// - [displayLarge], [display] - Maximum impact headers
/// - [headingLarge], [headingMedium], [headingSmall] - Section headers
/// - [bodyLarge], [body], [bodySmall] - Content text
/// - [labelLarge], [labelMedium], [labelSmall] - UI elements
///
/// **Font Families:**
/// - Londrina Solid: 100, 300, 400, 900 (display and headings)
/// - Fraunces: 100, 200, 300, 400, 500, 600, 700, 800, 900 (body and labels)
/// - Playpen Sans: Variable Font (body and labels)
///
/// See also:
/// * [InktomeColors] for color definitions
/// * [InktomeSpacing] for font sizes and layout
class InktomeTextStyles {
  InktomeTextStyles._();

  static const String headingFamily = 'LondrinaSolid';
  static const String labelFamily = 'LondrinaSolid';
  // static const String bodyFamily = 'PlaypenSans';
  static const String bodyFamily = 'NanumPenScript';

  // ? DISPLAY FONTS
  /// 89.7sp — Maximum impact. Single word or very short phrase only.
  static TextStyle get displayLarge => _displayLarge;
  static final TextStyle _displayLarge = TextStyle(
    fontFamily: headingFamily,
    fontSize: InktomeSpacing.displayLarge,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.5,
    height: 0.95,
  );

  /// 67.3sp - Large empty-state messages, prominent screen identifiers.
  static TextStyle get display => _display;
  static final TextStyle _display = TextStyle(
    fontFamily: headingFamily,
    fontSize: InktomeSpacing.display,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.0,
    height: 1.0,
  );

  // ? HEADING FONTS
  /// 48.0sp — Main screen titles
  static TextStyle get headingLarge => _headingLarge;
  static final TextStyle _headingLarge = TextStyle(
    fontFamily: headingFamily,
    fontSize: InktomeSpacing.headingLarge,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    height: 1.0,
  );

  /// 36.0sp - Section titles
  static TextStyle get headingMedium => _headingMedium;
  static final TextStyle _headingMedium = TextStyle(
    fontFamily: headingFamily,
    fontSize: InktomeSpacing.headingMedium,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.3,
    height: 1.0,
  );

  /// 28.0sp — Sub-section headers
  static TextStyle get headingSmall => _headingSmall;
  static final TextStyle _headingSmall = TextStyle(
    fontFamily: headingFamily,
    fontSize: InktomeSpacing.headingSmall,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.2,
    height: 1.0,
  );

  // MARK: BODY FONTS
  /// 22.0sp — Prominent text/subheadings
  static TextStyle get bodyLarge => _bodyLarge;
  static final TextStyle _bodyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: InktomeSpacing.bodyLarge,
    fontWeight: FontWeight.w200,
    height: 1.5,
  );

  /// 18.0sp — Standard body text.
  static TextStyle get body => _body;
  static final TextStyle _body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: InktomeSpacing.body,
    fontWeight: FontWeight.w200,
    height: 1.5,
  );

  /// 15.0sp — Secondary copy, supporting text, smaller descriptions.
  static TextStyle get bodySmall => _bodySmall;
  static final TextStyle _bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontSize: InktomeSpacing.bodySmall,
    fontWeight: FontWeight.w100,
    height: 1.5,
  );

  // MARK: LABEL FONTS
  /// 13.0sp — Tags, chips, UI labels.
  static TextStyle get labelLarge => _labelLarge;
  static final TextStyle _labelLarge = TextStyle(
    fontFamily: labelFamily,
    fontSize: InktomeSpacing.labelLarge,
    fontWeight: FontWeight.w100,
    height: 1.0,
  );

  /// 11.0sp — Captions, timestamps, nav labels, metadata.
  static TextStyle get label => _label;
  static final TextStyle _label = TextStyle(
    fontFamily: labelFamily,
    fontSize: InktomeSpacing.label,
    fontWeight: FontWeight.w100,
    height: 1.0,
  );

  /// 9.0sp — Fine print, de-emphasised hints.
  /// Close to minimum legible size — use sparingly.
  static TextStyle get labelSmall => _labelSmall;
  static final TextStyle _labelSmall = TextStyle(
    fontFamily: labelFamily,
    fontSize: InktomeSpacing.labelSmall,
    fontWeight: FontWeight.w100,
    height: 1.0,
  );

  // ? BUTTON STYLE
  /// 15.0sp — All button types (filled, outlined, text).
  static TextStyle get button => _button;
  static final TextStyle _button = TextStyle(
    fontFamily: labelFamily,
    fontSize: InktomeSpacing.buttonText,
    fontWeight: FontWeight.w100,
    height: 1.0,
  );
}
