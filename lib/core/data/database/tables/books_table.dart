import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/converters/book_status_converter.dart';
import 'package:inktome/core/data/database/converters/owned_format_converter.dart';

// MARK: BOOKS TABLE
//
// Central table — everything else hangs off this.
// Design notes:
//   - ISBNs are nullable because manually-entered books might not have one.
//   - cover_local_path + cover_source_url are kept separate deliberately.
//     Local path is what we show; source URL is the safety net for re-fetching.
//   - cached_status is intentionally named 'cached' — when reading sessions
//     land in a future version, status becomes derived from ReadInstance rows.
//     For MVP it acts as the source of truth.
//   - published_date is text, not int. The API returns varying precision
//     ("2003", "2003-08", "2003-08-26") and we don't want to discard that.
//   - rating is nullable — unrated books is a valid state.
//   - api_rating is the community/source rating; rating is the user's own.
//   - source tracks where metadata came from. Useful for debugging and
//     for handling data quality differently per provider.
//   - custom_data is a JSON blob escape hatch for arbitrary future fields.
//     Parse and serialise at the repository layer, never in UI code.

class Books extends Table {
  // Primary key — Drift auto-increments by default on IntColumn primaryKey.
  IntColumn get id => integer().autoIncrement()();

  // Core identity
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get isbn => text().nullable()();

  // Metadata from API or manual entry
  TextColumn get description => text().nullable()();
  TextColumn get publishedDate => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get publisher => text().nullable()();
  RealColumn get apiRating => real().nullable()();

  // Cover image — two columns, two jobs (see note above)
  TextColumn get coverLocalPath => text().nullable()();
  TextColumn get coverSourceUrl => text().nullable()();

  // Reading state
  // Valid values: 'to_read' | 'reading' | 'finished' | 'dnf'
  // Stored as text rather than an enum so the DB doesn't break
  // if we add new statuses without a migration.
  TextColumn get cachedStatus => text()
      .withDefault(const Constant('to_read'))
      .map(const BookStatusConverter())();

  // Ratings — both nullable; unrated is a valid state for each.
  // REAL in SQLite handles decimals (4.25, 4.75) with no issues.
  RealColumn get rating => real().nullable()();
  IntColumn get spiceRating => integer().nullable()();

  // Timestamps — unix seconds.
  // date_added is the only required one; others depend on reading state.
  IntColumn get dateAdded => integer()();
  IntColumn get dateStarted => integer().nullable()();
  IntColumn get dateFinished => integer().nullable()();

  // Ownership
  BoolColumn get isOwned => boolean().withDefault(const Constant(false))();
  TextColumn get ownedFormat =>
      text().nullable().map(const OwnedFormatConverter())();

  // NFC — nullable, unique. One sticker per book.
  // We only store the ID written to the sticker, not any raw tag data.
  TextColumn get nfcTagId => text().nullable().unique()();

  // Where the metadata came from.
  // Valid values: 'google_books' | 'open_library' | 'manual'
  TextColumn get source => text().withDefault(const Constant('manual'))();

  // Escape hatch for arbitrary future fields.
  // Stored as a JSON string; parse at repository layer, never in UI.
  TextColumn get customData => text().nullable()();
}
