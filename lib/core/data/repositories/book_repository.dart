import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/converters/book_status_converter'
    '.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/models/book_status.dart';

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
  //     ..orderBy([(b) => OrderingTerm.desc(b.dateAdded)]))
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

  /// Updates an existing book's fields.
  Future<bool> updateBook(BooksCompanion book) {
    return _db.update(_db.books).replace(book);
  }

  /// Deletes a book by ID. Notes cascade automatically (see schema).
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
}
