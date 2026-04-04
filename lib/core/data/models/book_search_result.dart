// MARK: BookSearchResult
//
// Represents a single result from the Google Books API.
// This is a transient view model — it never touches the database.
// When the user confirms adding a book, BookRepository.addBook()
// receives a BooksCompanion built from one of these.
class BookSearchResult {
  const BookSearchResult({
    required this.googleBooksId,
    required this.title,
    this.subtitle,
    this.authors = const [],
    this.description,
    this.publishedDate,
    this.pageCount,
    this.language,
    this.publisher,
    this.isbn,
    this.coverUrl,
    this.apiRating,
  });

  final String googleBooksId;
  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? description;
  final String? publishedDate;
  final int? pageCount;
  final String? language;
  final String? publisher;
  final String? isbn; // ISBN-13 preferred, ISBN-10 fallback
  final String?
  coverUrl; // cleaned https URL, ready to pass to CachedNetworkImage
  final double? apiRating;

  // Convenience — UI shows authors as a single string.
  String get authorDisplay =>
      authors.isEmpty ? 'Unknown Author' : authors.join(', ');

  // Converts this result into a map suitable for BooksCompanion.
  // Called when the user confirms adding this book to their library.
  Map<String, dynamic> toBookFields() => {
    'title': title,
    'subtitle': subtitle,
    'author': authorDisplay,
    'isbn': isbn,
    'description': description,
    'publishedDate': publishedDate,
    'pageCount': pageCount,
    'language': language,
    'publisher': publisher,
    'coverSourceUrl': coverUrl,
    'apiRating': apiRating,
    'source': 'google_books',
  };

  // Parses one item from the Google Books API response.
  // Returns null if the item is malformed or missing a title.
  static BookSearchResult? fromJson(Map<String, dynamic> json) {
    final info = json['volumeInfo'] as Map<String, dynamic>?;
    if (info == null) return null;

    final title = info['title'] as String?;
    if (title == null || title.isEmpty) return null;

    return BookSearchResult(
      googleBooksId: json['id'] as String? ?? '',
      title: title,
      subtitle: info['subtitle'] as String?,
      authors:
          (info['authors'] as List<dynamic>?)
              ?.map((a) => a as String)
              .toList() ??
          [],
      description: info['description'] as String?,
      publishedDate: info['publishedDate'] as String?,
      pageCount: info['pageCount'] as int?,
      language: info['language'] as String?,
      publisher: info['publisher'] as String?,
      isbn: _extractIsbn(info),
      coverUrl: _cleanCoverUrl(info),
      apiRating: (info['averageRating'] as num?)?.toDouble(),
    );
  }

  // Prefers ISBN-13 over ISBN-10.
  static String? _extractIsbn(Map<String, dynamic> info) {
    final identifiers = (info['industryIdentifiers'] as List<dynamic>?) ?? [];
    String? isbn10;
    for (final id in identifiers) {
      final map = id as Map<String, dynamic>;
      if (map['type'] == 'ISBN_13') return map['identifier'] as String?;
      if (map['type'] == 'ISBN_10') isbn10 = map['identifier'] as String?;
    }
    return isbn10;
  }

  // Enforces https, removes curl effect, upgrades zoom for a usable image.
  static String? _cleanCoverUrl(Map<String, dynamic> info) {
    final links = info['imageLinks'] as Map<String, dynamic>?;
    if (links == null) return null;

    // Prefer 'thumbnail' — 'smallThumbnail' is often too small to display.
    final raw = (links['thumbnail'] ?? links['smallThumbnail']) as String?;
    if (raw == null) return null;

    return raw
        .replaceFirst('http://', 'https://')
        .replaceAll('&edge=curl', '') // removes distracting page-curl rendering
        .replaceAll('zoom=1', 'zoom=0'); // zoom=0 gives a larger image
  }
}
