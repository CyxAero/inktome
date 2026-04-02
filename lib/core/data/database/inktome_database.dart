import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:inktome/core/data/database/tables/book_tags_table.dart';
import 'package:inktome/core/data/database/tables/books_table.dart';
import 'package:inktome/core/data/database/tables/notes_table.dart';
import 'package:inktome/core/data/database/tables/tags_table.dart';
import 'package:inktome/core/data/models/book_status.dart';
import 'package:inktome/core/data/models/owned_format.dart';
import 'package:inktome/core/data/database/converters/book_status_converter.dart';
import 'package:inktome/core/data/database/converters/owned_format_converter.dart';

// ReadInstances and ReadingSessions are defined but excluded from
// the @DriftDatabase annotation until we're ready to build that feature.
// When you add them: include them in the tables list, bump schemaVersion
// to 2, and add a migration step below.

part 'inktome_database.g.dart';

// MARK: Database

@DriftDatabase(tables: [Books, Notes, Tags, BookTags])
class InktomeDatabase extends _$InktomeDatabase {
  // InktomeDatabase() : super(_openConnection());
  InktomeDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  // schemaVersion must increment every time the schema changes.
  // Never edit a past migration — only add new steps.
  // Starting at 1. When ReadInstances/ReadingSessions are added: bump to 2.
  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'inktome_db');
  }

  // @override
  // MigrationStrategy get migration => MigrationStrategy(
  //   onCreate: (m) async {
  //     // Creates all tables on fresh install.
  //     await m.createAll();
  //   },
  //   onUpgrade: (m, from, to) async {
  //     // Future migrations go here. Example for when sessions land:
  //     //
  //     // if (from < 2) {
  //     //   await m.createTable(readInstances);
  //     //   await m.createTable(readingSessions);
  //     // }
  //   },
  // );
}

// Opens (or creates) the SQLite database file on the device.
// drift_flutter handles the platform-specific path for us.
// QueryExecutor _openConnection() {
//   return driftDatabase(name: 'inktome_db');
// }
