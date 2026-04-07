// import 'package:flutter/material.dart';
// import 'package:inktome/core/data/models/book_details.dart';
// import 'package:inktome/features/book_detail/streamed_books_detail_page.dart';
//
// // MARK: BookDetailPage
// // Entry points:
// //   1. Search results grid  → push('/book/preview', extra: BookDetails)
// //   2. Library grid          → push('/book/${book.id}')
// //
// // In case 1, BookDetails is passed via GoRouter's `extra` parameter.
// // The page is in preview mode: shows metadata, offers "Add to library".
// //
// // In case 2, the page receives a library book ID and watches the DB stream
// // directly. It's in edit mode: all fields are editable, status/rating visible.
// //
// // The page figures out which mode it's in via BookDetails.isInLibrary.
// // It never receives both a live stream AND an extra — only one source is active.
// class BookDetailPage extends StatelessWidget {
//   const BookDetailPage({super.key, required this.details});
//
//   final BookDetails details;
//
//   @override
//   Widget build(BuildContext context) {
//     // Library books get a live stream so edits reflect immediately.
//     // Search previews use the static BookDetails passed in via `extra`.
//     if (details.isInLibrary) {
//       // return _LiveDetailPage(libraryId: details.libraryId!, initial: details);
//       return StreamedBooksDetailPage(details: details);
//     }
//     return _PreviewDetailPage(details: details);
//   }
// }
