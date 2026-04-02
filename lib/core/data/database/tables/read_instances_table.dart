import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/tables/books_table.dart';

// MARK: ReadInstances Table — NOT in MVP, build later.
//
// A ReadInstance is one complete journey through a book.
// First read = instance 1. Reread = instance 2. And so on.
//
// Having this as a separate table (rather than columns on Book)
// is what makes rereads work cleanly. Each instance has its own
// start/end dates, status, and set of reading sessions.
//
// For MVP: skip this table. Use cached_status on Book directly.
// When you're ready to add it:
//   1. Increment schemaVersion in the database class.
//   2. Add a migration step that creates this table and populates
//      one ReadInstance row per book that has a non-null dateStarted.

class ReadInstances extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();

  // 1 = first read, 2 = first reread, etc.
  // Lets you order and display read history chronologically.
  IntColumn get instanceNum => integer().withDefault(const Constant(1))();

  // Valid values: 'reading' | 'finished' | 'abandoned'
  TextColumn get status => text().withDefault(const Constant('reading'))();

  IntColumn get startedAt => integer().nullable()();
  IntColumn get finishedAt => integer().nullable()();

  // Optional free-text thoughts specific to this read-through.
  // Different from Notes — this is a high-level reflection,
  // not a granular annotation.
  TextColumn get notes => text().nullable()();
}
