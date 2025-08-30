import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/pdf_document.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final int _maxMemoryCacheSize = 100 * 1024 * 1024; // 100MB
  final Duration _cacheExpiry = const Duration(hours: 24);

  // Cache PDF document in memory
  Future<void> cachePdfDocument(String documentId, Uint8List pdfData) async {
    try {
      // Check if we need to evict old entries
      _evictOldEntries();

      // Add to memory cache
      _memoryCache[documentId] = pdfData;
      _cacheTimestamps[documentId] = DateTime.now();

      // Also cache to disk
      await _cacheToDisk(documentId, pdfData);
    } catch (e) {
      // Log error but don't throw
      print('Failed to cache PDF document: $e');
    }
  }

  // Get cached PDF document
  Future<Uint8List?> getCachedPdfDocument(String documentId) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(documentId)) {
        final timestamp = _cacheTimestamps[documentId];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < _cacheExpiry) {
          return _memoryCache[documentId];
        } else {
          // Remove expired entry
          _memoryCache.remove(documentId);
          _cacheTimestamps.remove(documentId);
        }
      }

      // Check disk cache
      final cachedData = await _getFromDisk(documentId);
      if (cachedData != null) {
        // Add back to memory cache
        _memoryCache[documentId] = cachedData;
        _cacheTimestamps[documentId] = DateTime.now();
        return cachedData;
      }

      return null;
    } catch (e) {
      print('Failed to get cached PDF document: $e');
      return null;
    }
  }

  // Cache thumbnail
  Future<void> cacheThumbnail(
    String documentId,
    Uint8List thumbnailData,
  ) async {
    try {
      final cacheKey = 'thumbnail_$documentId';
      await _cacheToDisk(cacheKey, thumbnailData);
    } catch (e) {
      print('Failed to cache thumbnail: $e');
    }
  }

  // Get cached thumbnail
  Future<Uint8List?> getCachedThumbnail(String documentId) async {
    try {
      final cacheKey = 'thumbnail_$documentId';
      return await _getFromDisk(cacheKey);
    } catch (e) {
      print('Failed to get cached thumbnail: $e');
      return null;
    }
  }

  // Preload PDF pages for smooth scrolling
  Future<void> preloadPdfPages(
    String documentId,
    int startPage,
    int endPage,
  ) async {
    try {
      // In a real implementation, you would:
      // 1. Load the PDF document
      // 2. Render specified pages to images
      // 3. Cache the rendered pages

      print('Preloading pages $startPage to $endPage for document $documentId');
    } catch (e) {
      print('Failed to preload PDF pages: $e');
    }
  }

  // Optimize PDF for large files
  Future<String> optimizePdfForLargeFile(String pdfPath) async {
    try {
      final file = File(pdfPath);
      final fileSize = await file.length();

      // For files larger than 100MB, create a compressed version
      if (fileSize > 100 * 1024 * 1024) {
        return await _createCompressedVersion(pdfPath);
      }

      return pdfPath;
    } catch (e) {
      print('Failed to optimize PDF: $e');
      return pdfPath;
    }
  }

  // Create compressed version of PDF
  Future<String> _createCompressedVersion(String pdfPath) async {
    try {
      // In a real implementation, you would:
      // 1. Load the PDF document
      // 2. Reduce image quality
      // 3. Remove unnecessary metadata
      // 4. Save compressed version

      final tempDir = await getTemporaryDirectory();
      final compressedPath = path.join(
        tempDir.path,
        'compressed_${path.basename(pdfPath)}',
      );

      // For now, just copy the file
      await File(pdfPath).copy(compressedPath);

      return compressedPath;
    } catch (e) {
      print('Failed to create compressed version: $e');
      return pdfPath;
    }
  }

  // Lazy load PDF pages
  Future<Uint8List?> loadPdfPage(String documentId, int pageNumber) async {
    try {
      final cacheKey = 'page_${documentId}_$pageNumber';

      // Check cache first
      final cachedPage = await _getFromDisk(cacheKey);
      if (cachedPage != null) {
        return cachedPage;
      }

      // Load and render page
      final pageData = await _renderPdfPage(documentId, pageNumber);
      if (pageData != null) {
        await _cacheToDisk(cacheKey, pageData);
      }

      return pageData;
    } catch (e) {
      print('Failed to load PDF page: $e');
      return null;
    }
  }

  // Render PDF page to image
  Future<Uint8List?> _renderPdfPage(String documentId, int pageNumber) async {
    try {
      // In a real implementation, you would:
      // 1. Load the PDF document
      // 2. Render the specific page to an image
      // 3. Return the image data

      // For now, return null
      return null;
    } catch (e) {
      print('Failed to render PDF page: $e');
      return null;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      _memoryCache.clear();
      _cacheTimestamps.clear();

      final cacheDir = await getTemporaryDirectory();
      final pdfCacheDir = Directory(path.join(cacheDir.path, 'pdf_cache'));

      if (await pdfCacheDir.exists()) {
        await pdfCacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  // Clear specific document cache
  Future<void> clearDocumentCache(String documentId) async {
    try {
      _memoryCache.remove(documentId);
      _cacheTimestamps.remove(documentId);

      final cacheDir = await getTemporaryDirectory();
      final pdfCacheDir = Directory(path.join(cacheDir.path, 'pdf_cache'));

      if (await pdfCacheDir.exists()) {
        final files = await pdfCacheDir.list().toList();
        for (final file in files) {
          if (file.path.contains(documentId)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Failed to clear document cache: $e');
    }
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    final memorySize = _memoryCache.values.fold<int>(
      0,
      (sum, data) => sum + data.length,
    );

    return {
      'memoryCacheSize': memorySize,
      'memoryCacheEntries': _memoryCache.length,
      'maxMemoryCacheSize': _maxMemoryCacheSize,
      'cacheExpiry': _cacheExpiry.inHours,
    };
  }

  // Evict old entries from memory cache
  void _evictOldEntries() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheExpiry) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    // If still over limit, remove oldest entries
    if (_memoryCache.length > 10) {
      final sortedEntries =
          _cacheTimestamps.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value));

      while (_memoryCache.length > 5) {
        final oldestKey = sortedEntries.removeAt(0).key;
        _memoryCache.remove(oldestKey);
        _cacheTimestamps.remove(oldestKey);
      }
    }
  }

  // Cache data to disk
  Future<void> _cacheToDisk(String key, Uint8List data) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final pdfCacheDir = Directory(path.join(cacheDir.path, 'pdf_cache'));

      if (!await pdfCacheDir.exists()) {
        await pdfCacheDir.create(recursive: true);
      }

      final file = File(path.join(pdfCacheDir.path, key));
      await file.writeAsBytes(data);
    } catch (e) {
      print('Failed to cache to disk: $e');
    }
  }

  // Get data from disk cache
  Future<Uint8List?> _getFromDisk(String key) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final pdfCacheDir = Directory(path.join(cacheDir.path, 'pdf_cache'));

      if (!await pdfCacheDir.exists()) {
        return null;
      }

      final file = File(path.join(pdfCacheDir.path, key));
      if (await file.exists()) {
        return await file.readAsBytes();
      }

      return null;
    } catch (e) {
      print('Failed to get from disk cache: $e');
      return null;
    }
  }

  // Optimize memory usage
  void optimizeMemoryUsage() {
    _evictOldEntries();

    // Force garbage collection if available
    // Note: This is platform-specific and may not be available
  }

  // Monitor performance
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final cacheStats = getCacheStatistics();
      final tempDir = await getTemporaryDirectory();
      final pdfCacheDir = Directory(path.join(tempDir.path, 'pdf_cache'));

      int diskCacheSize = 0;
      int diskCacheFiles = 0;

      if (await pdfCacheDir.exists()) {
        final files = await pdfCacheDir.list().toList();
        diskCacheFiles = files.length;

        for (final file in files) {
          if (file is File) {
            diskCacheSize += await file.length();
          }
        }
      }

      return {
        ...cacheStats,
        'diskCacheSize': diskCacheSize,
        'diskCacheFiles': diskCacheFiles,
        'totalCacheSize': cacheStats['memoryCacheSize'] + diskCacheSize,
      };
    } catch (e) {
      print('Failed to get performance metrics: $e');
      return {};
    }
  }
}
