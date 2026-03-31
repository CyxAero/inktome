import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// MARK: ThemeNotifier

/// Owns the app-wide ThemeMode and persists it across sessions.
///
/// Consumed by MainApp (to drive MaterialApp.router's themeMode)
/// and by SettingsPage (to read + write the current selection).
///
/// Persistence is a single string key in shared_preferences —
/// 'theme_mode' → 'light' | 'dark' | 'system'.
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier(this._prefs) {
    _mode = _load();
  }

  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  late ThemeMode _mode;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _prefs.setString(_key, _encode(mode));
    notifyListeners();
  }

  ThemeMode _load() {
    return _decode(_prefs.getString(_key));
  }

  static String _encode(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _decode(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system, // default + unknown values
  };
}
