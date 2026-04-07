import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/converters/book_status_converter.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/models/book_details.dart';
import 'package:inktome/core/data/models/book_status.dart';
import 'package:inktome/core/data/models/owned_format.dart';
import 'package:inktome/core/data/models/read_format.dart';

// MARK: BookRepository
//
// All book-related database operations live here.
// UI never touches the database directly — it only calls these methods.
// That separation means if the schema changes, you fix it here, not
// scattered across every screen.
//
// Methods return either:
//   - Stream<T>  for things the UI should react to (library list, book detail)
//   - Future<T>  for one-shot operations (add, update, delete)

class BookRepository {
  BookRepository(this._db);

  final InktomeDatabase _db;

  // MARK: Streams (reactive — UI rebuilds when data changes)

  /// All books, ordered by date added descending (newest first).
  /// Use this to drive the library grid.
  Stream<List<Book>> watchAllBooks() {
    return (_db.select(
      _db.books,
    )..orderBy([(b) => OrderingTerm.desc(b.dateAdded)])).watch();
  }

  /// Books filtered by status.
  /// Valid statuses: 'to_read' | 'reading' | 'finished' | 'dnf'
  // Stream<List<Book>> watchBooksByStatus(BookStatus status) {
  //   return (_db.select(_db.books)
  //     ..where((b) => b.cachedStatus.equals(status))
  //     ..orderBy([(b) => OrderingTerm.desc(b.dateAdded)]))\
  //       .watch();
  // }
  Stream<List<Book>> watchBooksByStatus(BookStatus status) {
    return (_db.select(_db.books)
          ..where(
            (b) => b.cachedStatus.equals(
              const BookStatusConverter().toSql(status),
            ),
          )
          ..orderBy([(b) => OrderingTerm.desc(b.dateAdded)]))
        .watch();
  }

  /// Single book by ID — for the book detail screen.
  Stream<Book?> watchBook(int id) {
    return (_db.select(
      _db.books,
    )..where((b) => b.id.equals(id))).watchSingleOrNull();
  }

  // MARK: Futures (one-shot operations)

  /// Inserts a new book. Returns the new book's auto-generated ID.
  Future<int> addBook(BooksCompanion book) {
    return _db.into(_db.books).insert(book);
  }

  /// Full add: inserts a book, then writes genres and downloads the cover
  /// in one coordinated call. Returns the new book's ID.
  ///
  /// Prefer this over bare addBook() when adding from a search result —
  /// it keeps the genre wiring and cover download together so callers
  /// don't have to orchestrate three separate calls.
  Future<int> addBookWithDetails({
    required BooksCompanion companion,
    List<String> genreNames = const [],
  }) async {
    final id = await _db.into(_db.books).insert(companion);
    if (genreNames.isNotEmpty) {
      await setGenres(id, genreNames);
    }
    return id;
  }

  /// Updates an existing book's fields.
  Future<bool> updateBook(BooksCompanion book) {
    return _db.update(_db.books).replace(book);
  }

  /// Deletes a book by ID. Notes and genre links cascade automatically
  /// (see BookGenres and Notes table schemas — both use onDelete: cascade).
  Future<int> deleteBook(int id) {
    return (_db.delete(_db.books)..where((b) => b.id.equals(id))).go();
  }

  /// Updates just the reading status and relevant timestamps.
  /// Keeps the update focused — don't pass a full companion for a
  /// status change.
  Future<void> updateStatus(
    int bookId,
    BookStatus status, {
    int? dateStarted,
    int? dateFinished,
  }) {
    return (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(
        cachedStatus: Value(status),
        dateStarted: dateStarted != null
            ? Value(dateStarted)
            : const Value.absent(),
        dateFinished: dateFinished != null
            ? Value(dateFinished)
            : const Value.absent(),
      ),
    );
  }

  /// Updates the rating. Pass null to clear it.
  Future<void> updateRating(int bookId, double? rating) {
    return (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(rating: Value(rating)),
    );
  }

  /// Updates the read format (physical / ebook / audiobook).
  /// This is the MVP placeholder — long-term it moves to ReadInstances.
  Future<void> updateReadFormat(int bookId, ReadFormat? format) {
    return (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(readFormat: Value(format)),
    );
  }

  /// Updates owned status and format together — they always change as a pair.
  Future<void> updateOwnership(
    int bookId, {
    required bool isOwned,
    OwnedFormat? ownedFormat,
  }) {
    return (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(isOwned: Value(isOwned), ownedFormat: Value(ownedFormat)),
    );
  }

  /// Updates borrow state. Pass returnedAt to mark the book as returned.
  /// Pass null for returnedAt to mark it as still on loan.
  /// Set isBorrowed: false to clear the borrow record entirely.
  Future<void> updateBorrowState(
    int bookId, {
    required bool isBorrowed,
    String? borrowSource,
    int? borrowReturnedAt,
  }) {
    return (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(
        isBorrowed: Value(isBorrowed),
        borrowSource: Value(borrowSource),
        borrowReturnedAt: Value(borrowReturnedAt),
      ),
    );
  }

  /// Links an NFC tag ID to a book. Pass null to unlink.
  Future<void> linkNfcTag(int bookId, String? tagId) {
    return (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(nfcTagId: Value(tagId)),
    );
  }

  /// Looks up a book by NFC tag ID.
  /// Returns null if no book is linked to that tag.
  Future<Book?> findByNfcTag(String tagId) {
    return (_db.select(
      _db.books,
    )..where((b) => b.nfcTagId.equals(tagId))).getSingleOrNull();
  }

  /// Updates the local cover image path after downloading.
  Future<void> updateCoverPath(int bookId, String localPath) {
    return (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(coverLocalPath: Value(localPath)),
    );
  }

  // MARK: Genre Methods

  /// Returns the genre names for a given book, alphabetically sorted.
  /// Returns an empty list if the book has no genres.
  Future<List<String>> getGenreNames(int bookId) async {
    // Join BookGenres → Genres to get the names for this book's genre links.
    final query = _db.select(_db.bookGenres).join([
      innerJoin(_db.genres, _db.genres.id.equalsExp(_db.bookGenres.genreId)),
    ])..where(_db.bookGenres.bookId.equals(bookId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.genres).name).toList()..sort();
  }

  /// Replaces the genre list for a book.
  ///
  /// For each name:
  ///   1. INSERT OR IGNORE into Genres (so we don't duplicate existing genres).
  ///   2. Look up the genre's ID.
  ///   3. Upsert into BookGenres.
  ///
  /// Any genres previously linked to this book that are NOT in [genreNames]
  /// are deleted. Pass an empty list to clear all genres.
  Future<void> setGenres(int bookId, List<String> genreNames) async {
    await _db.transaction(() async {
      // Remove all existing genre links for this book.
      // We'll re-add the ones that should remain — simpler than diffing.
      await (_db.delete(
        _db.bookGenres,
      )..where((bg) => bg.bookId.equals(bookId))).go();

      for (final name in genreNames) {
        // Insert the genre name if it doesn't already exist.
        // insertOnConflictUpdate would overwrite; we only want to skip.
        await _db
            .into(_db.genres)
            .insert(
              GenresCompanion.insert(name: name),
              mode: InsertMode.insertOrIgnore,
            );

        // Fetch the ID (whether we just inserted it or it already existed).
        final genre = await (_db.select(
          _db.genres,
        )..where((g) => g.name.equals(name))).getSingleOrNull();

        if (genre == null) continue; // shouldn't happen, but guard anyway

        // Link this genre to the book.
        await _db
            .into(_db.bookGenres)
            .insert(
              BookGenresCompanion.insert(bookId: bookId, genreId: genre.id),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  // MARK: Composite Streams (book + genres together)

  /// Watches a single book and resolves its genres, returning a BookDetails.
  ///
  /// Emits a new value whenever the book row changes. Genre changes (which
  /// are writes, not streams) don't trigger a re-emit automatically — the
  /// caller should reload after a setGenres() call if the UI needs to reflect
  /// the change immediately.
  ///
  /// For a fully reactive genre stream you'd need a more complex join query;
  /// that's post-MVP complexity we don't need right now.
  Stream<BookDetails?> watchBookDetails(int id) {
    return watchBook(id).asyncMap((book) async {
      if (book == null) return null;
      final genres = await getGenreNames(id);
      return BookDetails.fromBook(book, genres: genres);
    });
  }
}
