import 'package:drift/drift.dart';
import 'package:inktome/core/data/models/read_format.dart';

// MARK: ReadFormatConverter
//
// Stores ReadFormat as a plain string in SQLite.
// Mirrors OwnedFormatConverter — nullable because the field is optional
// on both Books (MVP placeholder) and ReadInstances.
//
// IMPORTANT: the SQL strings below are the canonical values in the database.
// Never rename them without writing a migration that updates existing rows.

class ReadFormatConverter extends TypeConverter<ReadFormat?, String?> {
  const ReadFormatConverter();

  @override
  ReadFormat? fromSql(String? fromDb) => switch (fromDb) {
    'physical' => ReadFormat.physical,
    'ebook' => ReadFormat.ebook,
    'audiobook' => ReadFormat.audiobook,
    // 'pdf'       => ReadFormat.pdf,
    _ => null,
  };

  @override
  String? toSql(ReadFormat? value) => switch (value) {
    ReadFormat.physical => 'physical',
    ReadFormat.ebook => 'ebook',
    ReadFormat.audiobook => 'audiobook',
    // ReadFormat.pdf        => 'pdf',
    null => null,
  };
}
