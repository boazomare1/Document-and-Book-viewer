import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import '../models/pdf_document.dart';
import '../models/annotation.dart';
// import '../models/ai_features.dart';
import 'dart:convert'; // Added for json.encode/decode

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _databaseName = 'pdf_reader.db';
  static const int _databaseVersion = 1;

  // Database getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final documentsPath = await getDatabasesPath();
    final path = join(documentsPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Documents table
    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        thumbnail_path TEXT,
        last_opened TEXT NOT NULL,
        total_pages INTEGER NOT NULL,
        last_read_page INTEGER NOT NULL DEFAULT 1,
        file_size REAL NOT NULL,
        date_added TEXT NOT NULL,
        author TEXT,
        subject TEXT,
        keywords TEXT
      )
    ''');

    // Annotations table
    await db.execute('''
      CREATE TABLE annotations (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        type INTEGER NOT NULL,
        bounds TEXT NOT NULL,
        drawing_points TEXT,
        text TEXT,
        color TEXT NOT NULL,
        stroke_width REAL NOT NULL DEFAULT 2.0,
        created_at TEXT NOT NULL,
        modified_at TEXT,
        FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE
      )
    ''');

    // Table of contents table
    await db.execute('''
      CREATE TABLE table_of_contents (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        title TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        level INTEGER NOT NULL DEFAULT 0,
        parent_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES table_of_contents (id) ON DELETE CASCADE
      )
    ''');

    // AI features tables
    await db.execute('''
      CREATE TABLE document_summaries (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        summary TEXT NOT NULL,
        key_points TEXT NOT NULL,
        metadata TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE qa_responses (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        sources TEXT NOT NULL,
        confidence REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE translations (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        original_text TEXT NOT NULL,
        translated_text TEXT NOT NULL,
        source_language INTEGER NOT NULL,
        target_language INTEGER NOT NULL,
        confidence REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_annotations_document_page ON annotations (document_id, page_number)',
    );
    await db.execute(
      'CREATE INDEX idx_bookmarks_document ON bookmarks (document_id)',
    );
    await db.execute(
      'CREATE INDEX idx_toc_document ON table_of_contents (document_id)',
    );
    await db.execute(
      'CREATE INDEX idx_summaries_document ON document_summaries (document_id)',
    );
    await db.execute(
      'CREATE INDEX idx_qa_document ON qa_responses (document_id)',
    );
    await db.execute(
      'CREATE INDEX idx_translations_document ON translations (document_id)',
    );
  }

  // Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add new tables or modify existing ones
    }
  }

  // Document operations
  Future<void> saveDocument(PdfDocument document) async {
    final db = await database;
    await db.insert('documents', {
      'id': document.id,
      'name': document.name,
      'path': document.path,
      'thumbnail_path': document.thumbnailPath,
      'last_opened': document.lastOpened.toIso8601String(),
      'total_pages': document.totalPages,
      'last_read_page': document.lastReadPage,
      'file_size': document.fileSize,
      'date_added': document.dateAdded.toIso8601String(),
      'author': document.author,
      'subject': document.subject,
      'keywords': document.keywords,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PdfDocument>> getAllDocuments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      orderBy: 'last_opened DESC',
    );

    return List.generate(maps.length, (i) {
      return PdfDocument(
        id: maps[i]['id'],
        name: maps[i]['name'],
        path: maps[i]['path'],
        thumbnailPath: maps[i]['thumbnail_path'],
        lastOpened: DateTime.parse(maps[i]['last_opened']),
        totalPages: maps[i]['total_pages'],
        lastReadPage: maps[i]['last_read_page'],
        fileSize: maps[i]['file_size'],
        dateAdded: DateTime.parse(maps[i]['date_added']),
        author: maps[i]['author'],
        subject: maps[i]['subject'],
        keywords: maps[i]['keywords'],
      );
    });
  }

  Future<void> updateDocumentProgress(
    String documentId,
    int lastReadPage,
  ) async {
    final db = await database;
    await db.update(
      'documents',
      {
        'last_read_page': lastReadPage,
        'last_opened': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [documentId],
    );
  }

  Future<void> deleteDocument(String documentId) async {
    final db = await database;
    await db.delete('documents', where: 'id = ?', whereArgs: [documentId]);
  }

  // Annotation operations
  Future<void> saveAnnotation(Annotation annotation) async {
    final db = await database;
    await db.insert('annotations', {
      'id': annotation.id,
      'document_id': annotation.documentId,
      'page_number': annotation.pageNumber,
      'type': annotation.type.index,
      'bounds': annotation.bounds?.toJson().toString() ?? '',
      'drawing_points': annotation.points
          ?.map((p) => '${p.x},${p.y}')
          .join(';'),
      'content': annotation.content ?? '',
      'color': annotation.color.value,
      'stroke_width': annotation.strokeWidth ?? 2.0,
      'created_at': annotation.createdAt.toIso8601String(),
      'modified_at': annotation.modifiedAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Annotation>> getAnnotationsForDocument(String documentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'annotations',
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'page_number ASC, created_at ASC',
    );

    return List.generate(maps.length, (i) {
      final bounds =
          maps[i]['bounds'].split(',').map((s) => double.parse(s)).toList();
      final drawingPoints =
          maps[i]['drawing_points'] != null
              ? maps[i]['drawing_points'].split(';').map((point) {
                final coords = point.split(',');
                return AnnotationPoint(
                  double.parse(coords[0]),
                  double.parse(coords[1]),
                );
              }).toList()
              : null;

      return Annotation(
        id: maps[i]['id'],
        documentId: maps[i]['document_id'],
        pageNumber: maps[i]['page_number'],
        type: AnnotationType.values[maps[i]['type']],
        bounds:
            bounds.isNotEmpty
                ? AnnotationRectangle(
                  x: bounds[0],
                  y: bounds[1],
                  width: bounds[2],
                  height: bounds[3],
                )
                : null,
        points: drawingPoints,
        content: maps[i]['content'],
        color: Color(maps[i]['color']),
        strokeWidth: maps[i]['stroke_width'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        modifiedAt: DateTime.parse(maps[i]['modified_at']),
        author: 'Unknown', // TODO: Add author field to database
        opacity: 0.5, // TODO: Add opacity field to database
        isVisible: true, // TODO: Add isVisible field to database
        properties: {}, // TODO: Add properties field to database
        version: 1, // TODO: Add version field to database
      );
    });
  }

  Future<void> deleteAnnotation(String annotationId) async {
    final db = await database;
    await db.delete('annotations', where: 'id = ?', whereArgs: [annotationId]);
  }

  // Bookmark operations - TODO: Reimplement with new annotation system
  // Future<void> saveBookmark(Bookmark bookmark) async {
  //   // TODO: Implement bookmark functionality using annotation system
  // }

  // Future<List<Bookmark>> getBookmarksForDocument(String documentId) async {
  //   // TODO: Implement bookmark functionality using annotation system
  //   return [];
  // }

  // AI features operations - temporarily disabled
  // Future<void> saveDocumentSummary(DocumentSummary summary) async {
  //   // TODO: Implement when AI features are restored
  // }

  // Future<DocumentSummary?> getDocumentSummary(String documentId) async {
  //   // TODO: Implement when AI features are restored
  //   return null;
  // }

  // Future<void> saveQaResponse(QaResponse qaResponse) async {
  //   // TODO: Implement when AI features are restored
  // }

  // Future<List<QaResponse>> getQaResponsesForDocument(String documentId) async {
  //   // TODO: Implement when AI features are restored
  //   return [];
  // }

  // Settings operations
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return null;
    return maps.first['value'];
  }

  // Database maintenance
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('documents');
    await db.delete('annotations');
    await db.delete('bookmarks');
    await db.delete('table_of_contents');
    await db.delete('document_summaries');
    await db.delete('qa_responses');
    await db.delete('translations');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
