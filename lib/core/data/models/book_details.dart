import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/models/book_search_result.dart';
import 'package:inktome/core/data/models/book_status.dart';
import 'package:inktome/core/data/models/owned_format.dart';
import 'package:inktome/core/data/models/read_format.dart';

// MARK: BookDetails
//
// Unified, immutable presentation model for the book detail screen.
//
// Both BookSearchResult (transient API data) and Book (persisted Drift row)
// map into this. The detail page only ever sees BookDetails — it has no
// knowledge of either source type.
//
// COVER RESOLUTION:
// Use resolvedCoverPath — it prefers the local cached file over the remote URL.
//
// GENRES:
// Stored as a List<String> (genre names) for display.
// The genre IDs live in the BookGenres join table; the repository
// resolves names before handing data to the UI.
//
// BORROW TRACKING:
// isBorrowed is the primary flag. borrowSource is free text ("Sarah",
// "Hendon Library"). borrowReturnedAt is null while the book is still out.

class BookDetails {
  const BookDetails({
    this.libraryId,
    required this.title,
    this.subtitle,
    this.author,
    this.isbn,
    this.description,
    this.publishedDate,
    this.pageCount,
    this.language,
    this.publisher,
    this.apiRating,
    this.coverLocalPath,
    this.coverSourceUrl,
    this.genres = const [],
    this.status,
    this.rating,
    this.spiceRating,
    this.readFormat,
    this.dateAdded,
    this.dateStarted,
    this.dateFinished,
    this.isOwned = false,
    this.ownedFormat,
    this.isBorrowed = false,
    this.borrowSource,
    this.borrowReturnedAt,
    this.source,
    this.isEditable = false,
  });

  final int? libraryId;

  final String title;
  final String? subtitle;
  final String? author;
  final String? isbn;

  final String? description;
  final String? publishedDate;
  final int? pageCount;
  final String? language;
  final String? publisher;
  final double? apiRating;

  final String? coverLocalPath;
  final String? coverSourceUrl;

  // Genre names resolved from the BookGenres join table.
  // Empty list = no genres assigned (valid state).
  final List<String> genres;

  final BookStatus? status;
  final double? rating;
  final int? spiceRating;

  // The format the user is currently reading this book in.
  // Independent of ownedFormat.
  final ReadFormat? readFormat;

  final int? dateAdded;
  final int? dateStarted;
  final int? dateFinished;

  final bool isOwned;
  final OwnedFormat? ownedFormat;

  // Borrow tracking
  final bool isBorrowed;
  final String? borrowSource; // "Sarah", "Hendon Library", etc.
  final int? borrowReturnedAt; // unix seconds; null = not yet returned

  final String? source;

  /// True for library books. False for search result previews.
  final bool isEditable;

  // MARK: Derived State

  bool get isInLibrary => libraryId != null;

  /// Prefers on-disk cover; falls back to remote URL; null = show placeholder.
  String? get resolvedCoverPath => coverLocalPath ?? coverSourceUrl;

  String get authorDisplay =>
      author?.isNotEmpty == true ? author! : 'Unknown author';

  /// True if the book is borrowed and not yet returned.
  bool get isCurrentlyBorrowed => isBorrowed && borrowReturnedAt == null;

  // MARK: Factory — from search result

  factory BookDetails.fromSearchResult(
    BookSearchResult result, {
    // Genres aren't resolved yet at search time — they'll be inserted
    // into the DB on add. Pass them through as names for display.
    List<String>? genres,
  }) {
    return BookDetails(
      title: result.title,
      subtitle: result.subtitle,
      author: result.authorDisplay,
      isbn: result.isbn,
      description: result.description,
      publishedDate: result.publishedDate,
      pageCount: result.pageCount,
      language: result.language,
      publisher: result.publisher,
      apiRating: result.apiRating,
      coverSourceUrl: result.coverUrl,
      genres: genres ?? result.genres,
      source: 'google_books',
      isEditable: false,
    );
  }

  // MARK: Factory — from persisted library book

  factory BookDetails.fromBook(
    Book book, {
    // Genre names are resolved by the repository from the BookGenres join table.
    // Pass them in here — BookDetails doesn't query the DB itself.
    List<String> genres = const [],
  }) {
    return BookDetails(
      libraryId: book.id,
      title: book.title,
      subtitle: book.subtitle,
      author: book.author,
      isbn: book.isbn,
      description: book.description,
      publishedDate: book.publishedDate,
      pageCount: book.pageCount,
      language: book.language,
      publisher: book.publisher,
      apiRating: book.apiRating,
      coverLocalPath: book.coverLocalPath,
      coverSourceUrl: book.coverSourceUrl,
      genres: genres,
      status: book.cachedStatus,
      rating: book.rating,
      spiceRating: book.spiceRating,
      readFormat: book.readFormat,
      dateAdded: book.dateAdded,
      dateStarted: book.dateStarted,
      dateFinished: book.dateFinished,
      isOwned: book.isOwned,
      ownedFormat: book.ownedFormat,
      isBorrowed: book.isBorrowed,
      borrowSource: book.borrowSource,
      borrowReturnedAt: book.borrowReturnedAt,
      source: book.source,
      isEditable: true,
    );
  }

  // MARK: Conversion to companion (for inserting a new book)

  /// Builds a BooksCompanion for inserting this as a new library book.
  ///
  /// [localCoverPath] is optional — pass it if CoverService has already
  /// downloaded the cover by the time the user confirms adding the book.
  ///
  /// Genres are NOT included here — they're written separately via
  /// BookRepository.setGenres(bookId, genreNames) after the insert,
  /// because genres require two tables (Genres + BookGenres).
  BooksCompanion toNewBookCompanion({String? localCoverPath}) {
    return BooksCompanion.insert(
      title: title,
      subtitle: Value(subtitle),
      author: Value(author),
      isbn: Value(isbn),
      description: Value(description),
      publishedDate: Value(publishedDate),
      pageCount: Value(pageCount),
      language: Value(language),
      publisher: Value(publisher),
      apiRating: Value(apiRating),
      coverLocalPath: Value(localCoverPath),
      coverSourceUrl: Value(coverSourceUrl),
      cachedStatus: const Value(BookStatus.toRead),
      dateAdded: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      // dateAdded: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      source: Value(source ?? 'manual'),
      // Borrow fields default to false/null — user sets them after add if needed.
    );
  }
}
