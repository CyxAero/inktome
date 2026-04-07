import 'package:drift/drift.dart';

// MARK: Genres Table
//
// Canonical genre names — "Science Fiction", "Literary Fiction", etc.
// Name is unique so the same genre can't be inserted twice.
//
// WHY NOT JUST USE TAGS?
// Tags are personal, ad-hoc user labels ("borrowed from Alex", "beach read").
// Genres are descriptive categories with a life outside the user's head —
// they come from the Google Books API (volumeInfo.categories) and are
// shared vocabulary across books.
// Keeping them separate means you can filter the library by genre cleanly,
// without mixing in personal tags, and populate them automatically on add.
//
// POPULATING GENRES:
// When adding a book from Google Books, parse volumeInfo.categories and
// insert any new genre names (INSERT OR IGNORE), then link via BookGenres.
// For manual entries, the user picks from existing genres or types a new one.

class Genres extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Stored as-is from the API or user input. Uniqueness prevents duplicates.
  TextColumn get name => text().unique()();
}
