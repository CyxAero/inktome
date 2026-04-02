import 'package:drift/drift.dart';
import 'package:inktome/core/data/models/book_status.dart';

// Persists BookStatus as its snake_case string — readable in raw DB inspection.
class BookStatusConverter extends TypeConverter<BookStatus, String> {
  const BookStatusConverter();

  @override
  BookStatus fromSql(String fromDb) => switch (fromDb) {
    'to_read' => BookStatus.toRead,
    'reading' => BookStatus.reading,
    'finished' => BookStatus.finished,
    'dnf' => BookStatus.dnf,
    _ => BookStatus.toRead, // safe fallback
  };

  @override
  String toSql(BookStatus value) => switch (value) {
    BookStatus.toRead => 'to_read',
    BookStatus.reading => 'reading',
    BookStatus.finished => 'finished',
    BookStatus.dnf => 'dnf',
  };
}
