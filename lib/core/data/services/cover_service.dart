import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// MARK: CoverService
//
// Downloads a remote cover image and saves it to the app's documents directory.
//
// WHY CACHE COVERS:
// Google Books URLs are not stable — they can change or 404 after some time.
// Caching on-device means the library works fully offline and covers never
// disappear from books the user has already added.
//
// WHERE FILES LIVE:
// <app documents>/covers/<bookId>.jpg
// Using the book's database ID as the filename keeps it simple and avoids
// collisions. The directory is created on first use.
//
// USAGE:
// Call downloadAndSave() immediately after BookRepository.addBook() returns
// the new book ID. Then call BookRepository.updateCoverPath() with the result.
//
// If the download fails, log it and move on — the app falls back to the
// remote URL silently. Never block the user for a cover image.
//
// CUSTOM COVERS:
// For user-supplied covers (picked from gallery), call saveLocalFile() directly
// with the picked file's path. Same filename convention, same directory.

class CoverService {
  // Shared HTTP client — reuse across calls, don't create per-request.
  final _client = http.Client();

  // MARK: Download from URL
  /// Downloads the cover at [url] and saves it as covers/<bookId>.jpg.
  ///
  /// Returns the saved file path on success, null on any failure.
  /// Never throws — cover failure is always non-fatal.
  Future<String?> downloadAndSave({
    required int bookId,
    required String url,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('CoverService: HTTP ${response.statusCode} for $url');
        return null;
      }

      return _writeBytes(bookId: bookId, bytes: response.bodyBytes);
    } catch (e) {
      debugPrint('CoverService: download failed for book $bookId — $e');
      return null;
    }
  }

  // MARK: Copy from local file
  /// Copies a user-picked image file to the covers directory.
  ///
  /// Use this when the user replaces the cover with one from their gallery.
  /// Returns the saved file path on success, null on any failure.
  Future<String?> saveLocalFile({
    required int bookId,
    required String sourcePath,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('CoverService: source file not found at $sourcePath');
        return null;
      }
      final bytes = await sourceFile.readAsBytes();
      return _writeBytes(bookId: bookId, bytes: bytes);
    } catch (e) {
      debugPrint('CoverService: copy failed for book $bookId — $e');
      return null;
    }
  }

  // MARK: Delete
  /// Removes the cached cover for [bookId], if it exists.
  ///
  /// Call this when deleting a book so you don't orphan files on disk.
  Future<void> deleteCover(int bookId) async {
    try {
      final file = File(await _coverPath(bookId));
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('CoverService: delete failed for book $bookId — $e');
    }
  }

  // MARK: Private helpers
  /// Writes [bytes] to the covers directory and returns the absolute path.
  Future<String> _writeBytes({
    required int bookId,
    required Uint8List bytes,
  }) async {
    final dir = await _coversDirectory();
    final file = File('${dir.path}/$bookId.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Returns (and creates) the covers subdirectory inside app documents.
  Future<Directory> _coversDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/covers');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// The expected path for a given book ID — useful for existence checks
  /// without triggering a download.
  Future<String> _coverPath(int bookId) async {
    final dir = await _coversDirectory();
    return '${dir.path}/$bookId.jpg';
  }

  /// Clean up the HTTP client when this service is no longer needed.
  void dispose() => _client.close();
}
