import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/tables/read_instances_table.dart';

// MARK: ReadingSessions Table — NOT in MVP, build later.
//
// A ReadingSession is one timed sitting within a ReadInstance.
// Start the timer when you sit down to read; stop it when you're done.
//
// duration_secs is stored redundantly (it's end - start) but worth it:
//   - Queries like "total reading time this month" are a simple SUM,
//     no arithmetic on every row.
//   - Survives clock changes and timezone edge cases.
//
// page_start / page_end are optional — for users who want per-session
// page tracking. Don't force them if the user doesn't care.

class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get instanceId =>
      integer().references(ReadInstances, #id, onDelete: KeyAction.cascade)();

  IntColumn get startedAt => integer()();
  // Null while the session is active (timer running).
  IntColumn get endedAt => integer().nullable()();
  // Set when the session ends. Null while active.
  IntColumn get durationSecs => integer().nullable()();

  // Optional page tracking.
  IntColumn get pageStart => integer().nullable()();
  IntColumn get pageEnd => integer().nullable()();
}
