// MARK: BookSearchResult
//
// Represents a single result from the Google Books API.
// This is a transient view model — it never touches the database.
// When the user confirms adding a book, BookRepository.addBook()
// receives a BooksCompanion built from a BookDetails derived from this.

class BookSearchResult {
  const BookSearchResult({
    required this.googleBooksId,
    required this.title,
    this.subtitle,
    this.authors = const [],
    this.genres = const [],
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

  // Genre names from volumeInfo.categories.
  // The API returns these as broad strings like "Fiction / Science Fiction"
  // or just "Science Fiction". We store them as-is and let the user clean
  // up or rename genres if they want to.
  final List<String> genres;

  final String? description;
  final String? publishedDate;
  final int? pageCount;
  final String? language;
  final String? publisher;
  final String? isbn;
  final String? coverUrl;
  final double? apiRating;

  String get authorDisplay =>
      authors.isEmpty ? 'Unknown author' : authors.join(', ');

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
      genres: _extractGenres(info),
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

  // Parses volumeInfo.categories into a flat, deduplicated list.
  //
  // The API sometimes returns compound strings like "Fiction / Science Fiction".
  // We split on " / " so "Science Fiction" and "Fiction" become separate genres
  // rather than one unwieldy label. Duplicates are removed before returning.
  static List<String> _extractGenres(Map<String, dynamic> info) {
    final raw = (info['categories'] as List<dynamic>?) ?? [];
    return raw
        .expand((c) => (c as String).split(' / '))
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toSet() // deduplicate
        .toList();
  }

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

  static String? _cleanCoverUrl(Map<String, dynamic> info) {
    final links = info['imageLinks'] as Map<String, dynamic>?;
    if (links == null) return null;

    final raw = (links['thumbnail'] ?? links['smallThumbnail']) as String?;
    if (raw == null) return null;

    return raw
        .replaceFirst('http://', 'https://')
        .replaceAll('&edge=curl', '')
        .replaceAll('zoom=1', 'zoom=0');
  }
}
