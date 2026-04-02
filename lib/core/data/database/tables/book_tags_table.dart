import 'package:drift/drift.dart';
import 'package:inktome/core/data/database/tables/books_table.dart';
import 'package:inktome/core/data/database/tables/tags_table.dart';

// MARK: BookTags Join Table
//
// The many-to-many bridge between Books and Tags.
// A book can have many tags; a tag can apply to many books.
//
// Why not store tags as a comma-separated string on Book?
// Because you can't efficiently query "all books tagged X"
// without scanning every row. With this table, that's a
// single indexed lookup.
//
// Composite primary key (book_id + tag_id) means the same tag
// can't be applied to the same book twice.

class BookTags extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  // Drift requires this for composite primary keys.
  @override
  Set<Column> get primaryKey => {bookId, tagId};
}
