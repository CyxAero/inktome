import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/data/models/book_details.dart';
import 'package:inktome/core/features/home/home_page.dart';
import 'package:inktome/core/features/library/library_page.dart';
import 'package:inktome/core/features/settings/settings_page.dart';
import 'package:inktome/features/barcode_scanner/barcode_scanner_page.dart';
// import 'package:inktome/features/book_detail/book_detail_page.dart';
import 'package:inktome/features/book_detail/book_detail.dart';
import 'package:inktome/features/book_detail/streamed_books_detail_page.dart';
import 'package:inktome/features/book_search/book_search_page.dart';
import 'package:inktome/navigation/app_shell.dart';

/// All routes for Inktome.
///
/// ## Structure
///
/// The app uses a [ShellRoute] so the nav bar persists across the three
/// main tabs without rebuilding.
///
/// Routes inside the shell (tabs — nav bar always visible):
///   /home      → HomePage
///   /library   → LibraryPage
///   /settings  → SettingsPage
///
/// Routes outside the shell (full-screen — nav bar hidden):
///   /search             → BookSearchPage
///   /barcode-scan       → BarcodeScannerPage
///   /book/preview       → BookDetailPage (search result, not yet in library)
///   /book/:id           → BookDetailPage (library book, live DB stream)
///
/// ## Navigation conventions
///
/// Inside the shell:   context.go('/path')   — replaces, no back stack
/// Outside the shell:  context.push('/path') — pushes, back button works
///
/// ## Passing data to /book/preview
///
/// GoRouter's `extra` parameter carries the BookDetails object:
///   context.push('/book/preview', extra: BookDetails.fromSearchResult(result))
///
/// ## Adding a new full-screen route
///
/// Add a top-level GoRoute alongside the ShellRoute — NOT inside it.
/// That keeps it outside the shell so the nav bar never renders.

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // MARK: SHELL ROUTE
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LibraryPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),

    // MARK: FULL-SCREEN ROUTES
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) {
        final query = state.uri.queryParameters['q'];
        return MaterialPage(child: BookSearchPage(initialQuery: query));
      },
    ),

    GoRoute(
      path: '/barcode-scan',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: BarcodeScannerPage()),
    ),

    // Preview route — search result not yet in the library.
    // Receives a BookDetails via GoRouter's `extra` parameter.
    // Use: context.push('/book/preview', extra: BookDetails.fromSearchResult(r))
    // GoRoute(
    //   path: '/book/preview',
    //   pageBuilder: (context, state) {
    //     // If extra is somehow missing or wrong type, go home rather than crash.
    //     final details = state.extra;
    //     if (details is! BookDetails) {
    //       return const NoTransitionPage(child: HomePage());
    //     }
    //     return MaterialPage(child: BookDetailPage(details: details));
    //   },
    // ),

    // Library book route — book already in the DB, identified by integer ID.
    // The library grid passes a BookDetails via extra so the page can render
    // immediately from cached data while the stream spins up.
    // Use: context.push('/book/${book.id}', extra: BookDetails.fromBook(book))
    // GoRoute(
    //   path: '/book/:id',
    //   pageBuilder: (context, state) {
    //     final idStr = state.pathParameters['id'];
    //     final id = int.tryParse(idStr ?? '');
    //
    //     // Malformed ID — go home rather than crash.
    //     if (id == null) {
    //       return const NoTransitionPage(child: HomePage());
    //     }
    //
    //     // extra carries a BookDetails for instant rendering before the
    //     // stream emits. If it's absent (e.g. deep link), the page falls
    //     // back to showing a loading state until the stream fires.
    //     final extra = state.extra;
    //     final initialDetails = extra is BookDetails ? extra : null;
    //
    //     // If we have no initial details and the ID is valid, we still navigate
    //     // to the page — BookDetailPage handles the null case by showing a
    //     // loading indicator until the first stream emission.
    //     //
    //     // This also handles deep links and NFC tap-to-open, where there's
    //     // no pre-loaded BookDetails in memory.
    //     final placeholder =
    //         initialDetails ??
    //         BookDetails(
    //           libraryId: id,
    //           title: '', // empty title triggers loading state in the page
    //           isEditable: true,
    //         );
    //
    //     return MaterialPage(child: BookDetailPage(details: placeholder));
    //   },
    // ),
    // Search preview — book not yet in the library.
    // Use: context.push('/book/preview', extra: BookDetails.fromSearchResult(r))
    GoRoute(
      path: '/book/preview',
      pageBuilder: (context, state) {
        final details = state.extra;
        if (details is! BookDetails) {
          return const NoTransitionPage(child: HomePage());
        }
        // Fade transition lets the Hero fly without fighting a slide animation.
        // return _fadeRoute(child: StreamedBooksDetailPage(details: details));
        return MaterialPage(child: StreamedBooksDetailPage(details: details));
        // return _fadeRoute(child: NewBookDetail(details: details));
      },
    ),

    // Library book — identified by ID, BookDetails passed via extra for
    // instant first-frame render while the DB stream spins up.
    // Use: context.push('/book/${book.id}', extra: BookDetails.fromBook(book))
    GoRoute(
      path: '/book/:id',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return const NoTransitionPage(child: HomePage());

        final extra = state.extra;
        // Use passed BookDetails if available; otherwise build a minimal shell
        // that the StreamBuilder inside NewBookDetail will fill in immediately.
        final details = extra is BookDetails
            ? extra
            : BookDetails(libraryId: id, title: '', isEditable: true);

        return _fadeRoute(child: NewBookDetail(details: details));
        // return _fadeRoute(child: StreamedBooksDetailPage(details: details));
      },
    ),
  ],
);

// Fade-only transition — lets Hero widgets animate freely.
// The default MaterialPage slide competes with the Hero flight and looks wrong.
CustomTransitionPage<void> _fadeRoute({required Widget child}) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
