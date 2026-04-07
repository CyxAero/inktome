import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/converters/read_format_converter.dart';
import 'package:inktome/core/data/database/tables/books_table.dart';

// MARK: ReadInstances Table — NOT in MVP, build after submission.
//
// A ReadInstance is one complete journey through a book.
// First read = instance 1. Reread = instance 2. And so on.
//
// Having this as a separate table (rather than columns on Book)
// is what makes rereads work cleanly. Each instance has its own
// start/end dates, status, format, and set of reading sessions.
//
// SCHEMA v2 ADDITION:
//   - read_format — the format for this specific read-through.
//     This is the correct long-term home for read_format.
//     The Books.readFormat column is a temporary MVP placeholder
//     that should be deprecated once this table is active.
//
// When you're ready to activate this table:
//   1. Bump schemaVersion to 3 (it will be 2 once genres land).
//   2. Add ReadInstances + ReadingSessions to the @DriftDatabase tables list.
//   3. Write a migration that creates both tables and backfills one
//      ReadInstance row per book that has a non-null dateStarted,
//      copying Books.readFormat into ReadInstances.readFormat.
//   4. Deprecate (but don't yet drop) Books.readFormat — keep it until
//      you're confident the migration is clean in production.

class ReadInstances extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();

  // 1 = first read, 2 = first reread, etc.
  IntColumn get instanceNum => integer().withDefault(const Constant(1))();

  // Valid values: 'reading' | 'finished' | 'abandoned'
  TextColumn get status => text().withDefault(const Constant('reading'))();

  // The format for this specific read-through.
  // A user might own physical but listen to audiobook on a reread.
  TextColumn get readFormat =>
      text().nullable().map(const ReadFormatConverter())();

  IntColumn get startedAt => integer().nullable()();
  IntColumn get finishedAt => integer().nullable()();

  // High-level reflection on this specific read-through.
  // Separate from Notes (granular annotations) — this is a summary thought.
  TextColumn get notes => text().nullable()();
}
