class PdfDocument {
  final String id;
  final String name;
  final String path;
  final String? thumbnailPath;
  final DateTime lastOpened;
  final int totalPages;
  final int lastReadPage;
  final double fileSize;
  final DateTime dateAdded;
  final String? author;
  final String? subject;
  final String? keywords;

  PdfDocument({
    required this.id,
    required this.name,
    required this.path,
    this.thumbnailPath,
    required this.lastOpened,
    required this.totalPages,
    this.lastReadPage = 1,
    required this.fileSize,
    required this.dateAdded,
    this.author,
    this.subject,
    this.keywords,
  });

  PdfDocument copyWith({
    String? id,
    String? name,
    String? path,
    String? thumbnailPath,
    DateTime? lastOpened,
    int? totalPages,
    int? lastReadPage,
    double? fileSize,
    DateTime? dateAdded,
    String? author,
    String? subject,
    String? keywords,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      lastOpened: lastOpened ?? this.lastOpened,
      totalPages: totalPages ?? this.totalPages,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      fileSize: fileSize ?? this.fileSize,
      dateAdded: dateAdded ?? this.dateAdded,
      author: author ?? this.author,
      subject: subject ?? this.subject,
      keywords: keywords ?? this.keywords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'thumbnailPath': thumbnailPath,
      'lastOpened': lastOpened.toIso8601String(),
      'totalPages': totalPages,
      'lastReadPage': lastReadPage,
      'fileSize': fileSize,
      'dateAdded': dateAdded.toIso8601String(),
      'author': author,
      'subject': subject,
      'keywords': keywords,
    };
  }

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      thumbnailPath: json['thumbnailPath'],
      lastOpened: DateTime.parse(json['lastOpened']),
      totalPages: json['totalPages'],
      lastReadPage: json['lastReadPage'] ?? 1,
      fileSize: json['fileSize'],
      dateAdded: DateTime.parse(json['dateAdded']),
      author: json['author'],
      subject: json['subject'],
      keywords: json['keywords'],
    );
  }
}
