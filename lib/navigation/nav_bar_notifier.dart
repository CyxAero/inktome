import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';

// MARK: NavAction
/// Describes a single contextual action shown in the nav bar's action pill.
class NavAction {
  const NavAction({required this.icon, required this.onTap});
  final LucideAnimatedIconData icon;
  final VoidCallback onTap;
}

// MARK: NavBarNotifier
/// Manages the nav bar's contextual action and the add-book overlay visibility.
///
/// Scoped to [AppShell] via [ChangeNotifierProvider].
/// [overlayVisible] is watched by AppShell to add/remove the overlay widget
/// as a top-level Stack layer — above the nav bar.
class NavBarNotifier extends ChangeNotifier {
  NavAction? _action;
  bool _overlayVisible = false;

  NavAction? get action => _action;
  bool get hasAction => _action != null;
  bool get overlayVisible => _overlayVisible;

  void setAction(NavAction action) {
    _action = action;
    notifyListeners();
  }

  void clearAction() {
    _action = null;
    notifyListeners();
  }

  /// Shows the overlay and swaps the action pill to ×.
  void showOverlay({required VoidCallback closeAction}) {
    _overlayVisible = true;
    notifyListeners();
  }

  /// Hides the overlay. The active screen re-registers its own action
  /// via [didChangeDependencies], so we don't restore the + here.
  void hideOverlay() {
    _overlayVisible = false;
    notifyListeners();
  }
}
