import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/inktome_nav_bar.dart';
import 'package:inktome/features/add_book/add_book_overlay.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

/// The persistent shell that wraps all tab screens.
///
/// Stack layers (bottom → top):
///   1. Active tab screen
///   2. Floating nav bar (Positioned at bottom)
///   3. Add-book overlay (Positioned.fill, only when overlayVisible)
///
/// [PopScope] at the root intercepts Android back gestures and swipe-back
/// on iOS. When the overlay is open it dismisses it; otherwise it lets the
/// system handle the gesture (which would minimise the app from the root tab,
/// as expected).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _InktomeTab(label: 'home', path: '/home'),
    _InktomeTab(label: 'library', path: '/library'),
    _InktomeTab(label: 'settings', path: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _tabs.indexWhere(
      (tab) => location.startsWith(tab.path),
    );

    return ChangeNotifierProvider(
      create: (_) => NavBarNotifier(),
      child: AppBackground(
        child: _ShellStack(
          tabs: _tabs,
          selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
          child: child,
        ),
      ),
    );
  }
}

class _ShellStack extends StatelessWidget {
  const _ShellStack({
    required this.tabs,
    required this.selectedIndex,
    required this.child,
  });

  final List<_InktomeTab> tabs;
  final int selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final overlayVisible = context.select<NavBarNotifier, bool>(
      (n) => n.overlayVisible,
    );

    // PopScope intercepts the system back gesture.
    // canPop: false prevents the default behaviour (exiting the app).
    // onPopInvokedWithResult fires after the attempt:
    //   - if the overlay is open → dismiss it
    //   - if not → we allow normal popping by setting canPop based on
    //     whether the navigator has a route to pop to. From a root tab
    //     there is nothing to pop, so canPop is false and the system
    //     minimises the app, which is correct behaviour.
    return PopScope(
      canPop: !overlayVisible,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && overlayVisible) {
          dismissAddBookOverlay();
        }
      },
      child: Stack(
        children: [
          // LAYER 1: Active tab screen.
          // resizeToAvoidBottomInset is handled per-Scaffold in each tab
          // page (set to false), so the keyboard does not shift the shell.
          child,

          // LAYER 2: Floating nav bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: InktomeNavBar(
              tabs: tabs
                  .map((t) => NavTab(label: t.label, path: t.path))
                  .toList(),
              selectedIndex: selectedIndex,
              onTabSelected: (index) => context.go(tabs[index].path),
            ),
          ),

          // LAYER 3: Add-book overlay — above everything.
          if (overlayVisible) Positioned.fill(child: AddBookOverlayContent()),
        ],
      ),
    );
  }
}

class _InktomeTab {
  const _InktomeTab({required this.label, required this.path});
  final String label;
  final String path;
}
