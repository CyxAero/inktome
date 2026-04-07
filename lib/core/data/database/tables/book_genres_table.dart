import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/tables/books_table.dart';
import 'package:inktome/core/data/database/tables/genres_table.dart';

// MARK: BookGenres Join Table
//
// The many-to-many bridge between Books and Genres.
// A book can have many genres; a genre can apply to many books.
//
// Mirrors BookTags exactly in structure — same composite PK pattern,
// same cascade delete so genre links disappear when a book is deleted.
//
// Adding a genre to a book:
//   1. INSERT OR IGNORE INTO genres (name) VALUES (?)
//   2. SELECT id FROM genres WHERE name = ?
//   3. INSERT INTO book_genres (book_id, genre_id) VALUES (?, ?)
// (Or wrap in a repository method — UI never touches this directly.)

class BookGenres extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get genreId =>
      integer().references(Genres, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {bookId, genreId};
}
