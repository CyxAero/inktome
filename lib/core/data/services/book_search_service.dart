import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:inktome/core/data/models/book_search_result.dart';

// MARK: SearchResult
//
// A discriminated union for the three possible outcomes of a search.
// The page switches on this type — it never inspects raw exceptions.
sealed class SearchOutcome {
  const SearchOutcome();
}

class SearchSuccess extends SearchOutcome {
  const SearchSuccess(this.results);
  final List<BookSearchResult> results;
}

class SearchEmpty extends SearchOutcome {
  const SearchEmpty();
}

class SearchError extends SearchOutcome {
  const SearchError(this.message);
  final String message;
}

// MARK: BookSearchService
//
// Owns all communication with the Google Books API.
// Stateless — safe to share as a singleton via Provider.
//
// Responsibilities:
//   - Detect ISBNs and use isbn: prefix for exact lookups.
//   - Set a hard timeout so the UI never spins indefinitely.
//   - Deduplicate results by ISBN-13.
//   - Map every failure mode to a SearchOutcome the UI can act on.
class BookSearchService {
  BookSearchService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Tracks the current search generation. If a new search starts
  // before the previous one completes, the stale result is discarded.
  int _currentSearchId = 0;

  static const _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const _maxResults = 20;
  static const _timeout = Duration(seconds: 8);

  // Injected at build time via --dart-define=BOOKS_API_KEY=your_key.
  // Never hardcode a key here. Empty string means unauthenticated (dev only).
  static const _apiKey = String.fromEnvironment(
    'BOOKS_API_KEY',
    defaultValue: '',
  );

  // MARK: search
  //
  // The single public entry point. Callers never touch the HTTP layer.
  // Returns a SearchOutcome the UI switches on directly.
  Future<SearchOutcome> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return const SearchEmpty();

    // Increment generation — any in-flight request with an older ID
    // will see the mismatch and discard its result.
    final searchId = ++_currentSearchId;

    final uri = _buildUri(query);

    try {
      final response = await _client.get(uri).timeout(_timeout);

      // Stale — a newer search was submitted while this one was in flight.
      if (searchId != _currentSearchId) return const SearchEmpty();

      // if (response.statusCode != 200) {
      //   debugPrint('BookSearchService: HTTP ${response.statusCode} for $uri');
      //   return const SearchError('Search failed. Please try again.');
      // }
      if (response.statusCode != 200) {
        debugPrint('BookSearchService: HTTP ${response.statusCode}');
        debugPrint('BookSearchService: body — ${response.body}');
        return const SearchError('Search failed. Please try again.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['items'] as List<dynamic>?;

      // API returns 200 with no 'items' key when there are no results.
      if (items == null || items.isEmpty) return const SearchEmpty();

      final results = _parseAndDeduplicate(items);
      return results.isEmpty ? const SearchEmpty() : SearchSuccess(results);
    } on TimeoutException {
      return const SearchError('Search timed out. Check your connection.');
    } on SocketException {
      return const SearchError('No internet connection.');
    } on FormatException {
      // JSON decode failed — API returned unexpected content.
      return const SearchError('Unexpected response from server.');
    } catch (e) {
      debugPrint('BookSearchService: unexpected error — $e');
      return const SearchError('Something went wrong. Please try again.');
    }
  }

  // MARK: URI building
  //
  // ISBN queries use the isbn: prefix for exact lookups — significantly
  // more accurate than treating the number as a text query.
  // Everything else uses a plain text search with +intitle: bias
  // to push title matches to the top of results.
  Uri _buildUri(String query) {
    final stripped = query.replaceAll(RegExp(r'[\s\-]'), '');
    final isIsbn = RegExp(r'^\d{10}$|^\d{13}$').hasMatch(stripped);

    // ISBN queries use the isbn: prefix — far more accurate than treating
    // the number as a text search. Strips hyphens and spaces first so
    // '978-0-06-231609-7' and '9780062316097' both resolve correctly.
    final q = isIsbn ? 'isbn:$stripped' : query;

    return Uri.parse(_baseUrl).replace(
      queryParameters: {
        'q': q,

        // Cap at 20 — the free tier handles this fine and keeps response
        // payloads small. Increase only if you add pagination later.
        'maxResults': '$_maxResults',

        // Fields projection — only request what BookSearchResult.fromJson
        // actually reads. Cuts response payload by roughly 60% and keeps
        // the request fast on slow connections.
        'fields':
            'items(id,volumeInfo(title,subtitle,authors,description,'
            'publishedDate,pageCount,language,publisher,'
            'industryIdentifiers,imageLinks,averageRating))',

        // Exclude magazines and journals — Books API returns them by default.
        'printType': 'books',

        // Only inject the key when it's been provided via --dart-define.
        // Omitting the parameter entirely falls back to unauthenticated
        // requests, which is fine for local dev before you have a key.
        if (_apiKey.isNotEmpty) 'key': _apiKey,
      },
    );
  }
  // Uri _buildUri(String query) {
  //   final isIsbn = RegExp(
  //     r'^\d{10}$|^\d{13}$',
  //   ).hasMatch(query.replaceAll('-', '').replaceAll(' ', ''));
  //
  //   final q = isIsbn
  //       ? 'isbn:${query.replaceAll('-', '').replaceAll(' ', '')}'
  //       : query;
  //
  //   return Uri.parse(_baseUrl).replace(
  //     queryParameters: {
  //       'q': q,
  //       'maxResults': '$_maxResults',
  //       // Fields projection — only fetch what we actually use.
  //       // This reduces response payload by ~60% vs fetching everything.
  //       'fields':
  //           'items(id,volumeInfo(title,subtitle,authors,description,publishedDate,'
  //           'pageCount,language,publisher,industryIdentifiers,imageLinks,averageRating))',
  //       'printType': 'books', // exclude magazines
  //       'langRestrict': 'en', // remove if you want multi-language results
  //     },
  //   );
  // }

  // MARK: Parsing and deduplication
  //
  // Deduplicates by ISBN-13 — the API occasionally returns the same
  // book as multiple volumes (different editions, same ISBN).
  // Books without an ISBN are kept, since we can't know they're duplicates.
  List<BookSearchResult> _parseAndDeduplicate(List<dynamic> items) {
    final seen = <String>{};
    final results = <BookSearchResult>[];

    for (final item in items) {
      final result = BookSearchResult.fromJson(item as Map<String, dynamic>);
      if (result == null) continue;

      if (result.isbn != null) {
        if (!seen.add(result.isbn!)) continue; // duplicate — skip
      }

      results.add(result);
    }

    return results;
  }

  void dispose() => _client.close();
}
