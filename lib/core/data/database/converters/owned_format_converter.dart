import 'package:drift/drift.dart';
import 'package:inktome/core/data/models/owned_format.dart';

class OwnedFormatConverter extends TypeConverter<OwnedFormat?, String?> {
  const OwnedFormatConverter();

  @override
  OwnedFormat? fromSql(String? fromDb) => switch (fromDb) {
    'physical' => OwnedFormat.physical,
    'ebook' => OwnedFormat.ebook,
    'audiobook' => OwnedFormat.audiobook,
    'pdf' => OwnedFormat.pdf,
    _ => null,
  };

  @override
  String? toSql(OwnedFormat? value) => switch (value) {
    OwnedFormat.physical => 'physical',
    OwnedFormat.ebook => 'ebook',
    OwnedFormat.audiobook => 'audiobook',
    OwnedFormat.pdf => 'pdf',
    null => null,
  };
}
