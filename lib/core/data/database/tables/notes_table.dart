import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/tables/books_table.dart';

// MARK: Notes Table
//
// One book can have many notes — a quote log, a review draft,
// a "why I bought this" note, whatever the user wants.
// Content is stored as Markdown text.
//
// No 'title' column — the first line of the markdown content
// serves as a natural title in the UI. Avoids the awkward
// "title your note" prompt that most apps force on you.

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Foreign key to Books.id.
  // onDelete: cascade means if the book is deleted, all its notes
  // go with it. No orphaned note rows.
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();

  TextColumn get content => text()();

  // Both timestamps in unix seconds.
  // created_at is set once on insert; updated_at changes on every edit.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}
