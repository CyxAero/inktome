import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/converters/book_status_converter.dart';
import 'package:inktome/core/data/database/converters/owned_format_converter.dart';
import 'package:inktome/core/data/database/converters/read_format_converter.dart';

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
//   - source tracks where metadata came from.
//   - custom_data is a JSON blob escape hatch for arbitrary future fields.
//
// SCHEMA v2 ADDITIONS:
//   - is_borrowed / borrow_source / borrow_returned_at — borrow tracking.
//     borrow_source is free text ("Sarah", "Hendon Library") — not a FK
//     because these are informal references, not database entities.
//   - read_format — MVP placeholder for the format the user is reading in.
//     Moves to ReadInstances long-term; kept here until that table is active.
//     Separate from owned_format: you can own a physical copy while
//     listening to the library audiobook.

class Books extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Core identity
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get isbn => text().nullable()();

  // Metadata
  TextColumn get description => text().nullable()();
  TextColumn get publishedDate => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get publisher => text().nullable()();
  RealColumn get apiRating => real().nullable()();

  // Cover
  TextColumn get coverLocalPath => text().nullable()();
  TextColumn get coverSourceUrl => text().nullable()();

  // Reading state
  TextColumn get cachedStatus => text()
      .withDefault(const Constant('to_read'))
      .map(const BookStatusConverter())();

  // Ratings
  RealColumn get rating => real().nullable()();
  IntColumn get spiceRating => integer().nullable()();

  // Timestamps (unix seconds)
  IntColumn get dateAdded => integer()();
  IntColumn get dateStarted => integer().nullable()();
  IntColumn get dateFinished => integer().nullable()();

  // Ownership
  BoolColumn get isOwned => boolean().withDefault(const Constant(false))();
  TextColumn get ownedFormat =>
      text().nullable().map(const OwnedFormatConverter())();

  // SCHEMA v2: Read format (MVP placeholder — migrates to ReadInstances later)
  // The format the user is currently reading this book in.
  // Independent of ownedFormat: owning a physical copy doesn't mean
  // you're not listening to the audiobook on your commute.
  TextColumn get readFormat =>
      text().nullable().map(const ReadFormatConverter())();

  // SCHEMA v2: Borrow tracking
  // is_borrowed is the primary flag. borrow_source is who/where it came from.
  // borrow_returned_at is null while the book is still out on loan.
  BoolColumn get isBorrowed => boolean().withDefault(const Constant(false))();
  TextColumn get borrowSource => text().nullable()();
  IntColumn get borrowReturnedAt => integer().nullable()();

  // NFC
  TextColumn get nfcTagId => text().nullable().unique()();

  // Source
  TextColumn get source => text().withDefault(const Constant('manual'))();

  // Escape hatch
  TextColumn get customData => text().nullable()();
}
