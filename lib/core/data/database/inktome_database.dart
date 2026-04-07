import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:inktome/core/data/database/converters/book_status_converter.dart';
import 'package:inktome/core/data/database/converters/owned_format_converter.dart';
import 'package:inktome/core/data/database/converters/read_format_converter.dart';
import 'package:inktome/core/data/database/tables/book_genres_table.dart';
import 'package:inktome/core/data/database/tables/book_tags_table.dart';
import 'package:inktome/core/data/database/tables/books_table.dart';
import 'package:inktome/core/data/database/tables/genres_table.dart';
import 'package:inktome/core/data/database/tables/notes_table.dart';
import 'package:inktome/core/data/database/tables/tags_table.dart';
import 'package:inktome/core/data/models/book_status.dart';
import 'package:inktome/core/data/models/owned_format.dart';
import 'package:inktome/core/data/models/read_format.dart';

// ReadInstances and ReadingSessions are defined but excluded from the
// @DriftDatabase annotation until the session-tracking feature is built.
// When you add them:
//   - Include them in the tables list below.
//   - Bump schemaVersion to 3.
//   - Add a migration step in the onUpgrade handler.

part 'inktome_database.g.dart';

// MARK: Database

@DriftDatabase(tables: [Books, Notes, Tags, BookTags, Genres, BookGenres])
class InktomeDatabase extends _$InktomeDatabase {
  InktomeDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  // MARK: Schema Version
  //
  // v1 → initial schema (Books, Notes, Tags, BookTags)
  // v2 → added: Books.readFormat, Books.isBorrowed, Books.borrowSource,
  //              Books.borrowReturnedAt, Genres, BookGenres
  //
  // NEVER edit a past migration — only ever add new steps below.
  // NEVER reset schemaVersion to 1 on a new feature — always increment.
  @override
  int get schemaVersion => 2;

  // MARK: Migrations
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // Fresh install — create every table in one shot.
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Always run migrations inside a transaction so a partial failure
      // doesn't leave the schema in a broken intermediate state.
      await transaction(() async {
        // v1 → v2
        if (from < 2) {
          // Add borrow-tracking columns to Books.
          // ALTER TABLE in SQLite can only add one column per statement,
          // hence three separate calls.
          await m.addColumn(books, books.isBorrowed);
          await m.addColumn(books, books.borrowSource);
          await m.addColumn(books, books.borrowReturnedAt);

          // Add read_format to Books (MVP placeholder).
          await m.addColumn(books, books.readFormat);

          // Create the new Genres and BookGenres tables.
          await m.createTable(genres);
          await m.createTable(bookGenres);
        }

        // v2 → v3 will go here when ReadInstances/ReadingSessions land.
        // if (from < 3) { ... }
      });
    },
    // beforeOpen runs after migrations, before the app starts using the DB.
    // Good place for SQLite-specific configuration that need to be set
    // per-connection.
    beforeOpen: (details) async {
      // Enable foreign key enforcement. SQLite disables this by default —
      // without it, cascade deletes won't fire and orphaned rows accumulate.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'inktome_db');
  }
}
