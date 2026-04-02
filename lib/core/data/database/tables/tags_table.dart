import 'package:drift/drift.dart';

// MARK: Tags Table
//
// User-defined labels — "sci-fi", "borrowed from Alex", "reread", anything.
// Name is unique so you can't accidentally create duplicate tags.

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}
