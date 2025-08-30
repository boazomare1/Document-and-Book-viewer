import 'package:flutter/material.dart';

enum AnnotationType {
  textHighlight,
  underline,
  strikethrough,
  stickyNote,
  stamp,
  redaction,
  lassoSelect,
  drawing,
  text,
  shape,
}

enum StampType { approved, rejected, draft, confidential, urgent, custom }

class TableOfContentsItem {
  final String title;
  final int pageNumber;
  final int level;
  final List<TableOfContentsItem> children;

  const TableOfContentsItem({
    required this.title,
    required this.pageNumber,
    this.level = 0,
    this.children = const [],
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'pageNumber': pageNumber,
    'level': level,
    'children': children.map((child) => child.toJson()).toList(),
  };

  factory TableOfContentsItem.fromJson(Map<String, dynamic> json) {
    return TableOfContentsItem(
      title: json['title'] as String,
      pageNumber: json['pageNumber'] as int,
      level: json['level'] as int? ?? 0,
      children:
          (json['children'] as List<dynamic>?)
              ?.map(
                (child) =>
                    TableOfContentsItem.fromJson(child as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class AnnotationPoint {
  final double x;
  final double y;

  const AnnotationPoint(this.x, this.y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory AnnotationPoint.fromJson(Map<String, dynamic> json) {
    return AnnotationPoint(json['x'] as double, json['y'] as double);
  }
}

class AnnotationRectangle {
  final double x;
  final double y;
  final double width;
  final double height;

  const AnnotationRectangle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };

  factory AnnotationRectangle.fromJson(Map<String, dynamic> json) {
    return AnnotationRectangle(
      x: json['x'] as double,
      y: json['y'] as double,
      width: json['width'] as double,
      height: json['height'] as double,
    );
  }
}

class Annotation {
  final String id;
  final String documentId;
  final AnnotationType type;
  final int pageNumber;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String author;
  final String? content;
  final Color color;
  final double opacity;
  final bool isVisible;
  final Map<String, dynamic> properties;

  // Text annotations
  final String? selectedText;
  final List<int>? textRanges;
  final AnnotationRectangle? bounds;

  // Drawing annotations
  final List<AnnotationPoint>? points;
  final double? strokeWidth;
  final bool? isFilled;

  // Sticky notes
  final AnnotationPoint? notePosition;
  final String? noteText;
  final bool? isOpen;

  // Stamps
  final StampType? stampType;
  final String? stampText;
  final String? stampImagePath;

  // Redaction
  final bool? isRedacted;
  final String? redactionReason;

  // Version history
  final String? parentId;
  final int version;
  final List<String>? tags;

  const Annotation({
    required this.id,
    required this.documentId,
    required this.type,
    required this.pageNumber,
    required this.createdAt,
    required this.modifiedAt,
    required this.author,
    this.content,
    required this.color,
    required this.opacity,
    required this.isVisible,
    required this.properties,
    this.selectedText,
    this.textRanges,
    this.bounds,
    this.points,
    this.strokeWidth,
    this.isFilled,
    this.notePosition,
    this.noteText,
    this.isOpen,
    this.stampType,
    this.stampText,
    this.stampImagePath,
    this.isRedacted,
    this.redactionReason,
    this.parentId,
    required this.version,
    this.tags,
  });

  Annotation copyWith({
    String? id,
    String? documentId,
    AnnotationType? type,
    int? pageNumber,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? author,
    String? content,
    Color? color,
    double? opacity,
    bool? isVisible,
    Map<String, dynamic>? properties,
    String? selectedText,
    List<int>? textRanges,
    AnnotationRectangle? bounds,
    List<AnnotationPoint>? points,
    double? strokeWidth,
    bool? isFilled,
    AnnotationPoint? notePosition,
    String? noteText,
    bool? isOpen,
    StampType? stampType,
    String? stampText,
    String? stampImagePath,
    bool? isRedacted,
    String? redactionReason,
    String? parentId,
    int? version,
    List<String>? tags,
  }) {
    return Annotation(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      type: type ?? this.type,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      author: author ?? this.author,
      content: content ?? this.content,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      properties: properties ?? this.properties,
      selectedText: selectedText ?? this.selectedText,
      textRanges: textRanges ?? this.textRanges,
      bounds: bounds ?? this.bounds,
      points: points ?? this.points,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isFilled: isFilled ?? this.isFilled,
      notePosition: notePosition ?? this.notePosition,
      noteText: noteText ?? this.noteText,
      isOpen: isOpen ?? this.isOpen,
      stampType: stampType ?? this.stampType,
      stampText: stampText ?? this.stampText,
      stampImagePath: stampImagePath ?? this.stampImagePath,
      isRedacted: isRedacted ?? this.isRedacted,
      redactionReason: redactionReason ?? this.redactionReason,
      parentId: parentId ?? this.parentId,
      version: version ?? this.version,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'type': type.name,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'author': author,
      'content': content,
      'color': color.toARGB32(),
      'opacity': opacity,
      'isVisible': isVisible,
      'properties': properties,
      'selectedText': selectedText,
      'textRanges': textRanges,
      'bounds': bounds?.toJson(),
      'points': points?.map((p) => p.toJson()).toList(),
      'strokeWidth': strokeWidth,
      'isFilled': isFilled,
      'notePosition': notePosition?.toJson(),
      'noteText': noteText,
      'isOpen': isOpen,
      'stampType': stampType?.name,
      'stampText': stampText,
      'stampImagePath': stampImagePath,
      'isRedacted': isRedacted,
      'redactionReason': redactionReason,
      'parentId': parentId,
      'version': version,
      'tags': tags,
    };
  }

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      type: AnnotationType.values.firstWhere((e) => e.name == json['type']),
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      author: json['author'] as String,
      content: json['content'] as String?,
      color: Color(json['color'] as int),
      opacity: json['opacity'] as double,
      isVisible: json['isVisible'] as bool,
      properties: Map<String, dynamic>.from(json['properties'] as Map),
      selectedText: json['selectedText'] as String?,
      textRanges:
          json['textRanges'] != null
              ? List<int>.from(json['textRanges'] as List)
              : null,
      bounds:
          json['bounds'] != null
              ? AnnotationRectangle.fromJson(
                json['bounds'] as Map<String, dynamic>,
              )
              : null,
      points:
          json['points'] != null
              ? (json['points'] as List)
                  .map(
                    (p) => AnnotationPoint.fromJson(p as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      strokeWidth: json['strokeWidth'] as double?,
      isFilled: json['isFilled'] as bool?,
      notePosition:
          json['notePosition'] != null
              ? AnnotationPoint.fromJson(
                json['notePosition'] as Map<String, dynamic>,
              )
              : null,
      noteText: json['noteText'] as String?,
      isOpen: json['isOpen'] as bool?,
      stampType:
          json['stampType'] != null
              ? StampType.values.firstWhere((e) => e.name == json['stampType'])
              : null,
      stampText: json['stampText'] as String?,
      stampImagePath: json['stampImagePath'] as String?,
      isRedacted: json['isRedacted'] as bool?,
      redactionReason: json['redactionReason'] as String?,
      parentId: json['parentId'] as String?,
      version: json['version'] as int,
      tags:
          json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Annotation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Annotation(id: $id, type: $type, pageNumber: $pageNumber, author: $author)';
  }
}

class AnnotationVersion {
  final String id;
  final String annotationId;
  final Annotation annotation;
  final DateTime timestamp;
  final String author;
  final String changeDescription;

  const AnnotationVersion({
    required this.id,
    required this.annotationId,
    required this.annotation,
    required this.timestamp,
    required this.author,
    required this.changeDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'annotationId': annotationId,
      'annotation': annotation.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'author': author,
      'changeDescription': changeDescription,
    };
  }

  factory AnnotationVersion.fromJson(Map<String, dynamic> json) {
    return AnnotationVersion(
      id: json['id'] as String,
      annotationId: json['annotationId'] as String,
      annotation: Annotation.fromJson(
        json['annotation'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      author: json['author'] as String,
      changeDescription: json['changeDescription'] as String,
    );
  }
}

class AnnotationLayer {
  final String id;
  final String name;
  final String documentId;
  final bool isVisible;
  final bool isLocked;
  final Color color;
  final double opacity;
  final List<Annotation> annotations;

  const AnnotationLayer({
    required this.id,
    required this.name,
    required this.documentId,
    required this.isVisible,
    required this.isLocked,
    required this.color,
    required this.opacity,
    required this.annotations,
  });

  AnnotationLayer copyWith({
    String? id,
    String? name,
    String? documentId,
    bool? isVisible,
    bool? isLocked,
    Color? color,
    double? opacity,
    List<Annotation>? annotations,
  }) {
    return AnnotationLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      documentId: documentId ?? this.documentId,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      annotations: annotations ?? this.annotations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'documentId': documentId,
      'isVisible': isVisible,
      'isLocked': isLocked,
      'color': color.toARGB32(),
      'opacity': opacity,
      'annotations': annotations.map((a) => a.toJson()).toList(),
    };
  }

  factory AnnotationLayer.fromJson(Map<String, dynamic> json) {
    return AnnotationLayer(
      id: json['id'] as String,
      name: json['name'] as String,
      documentId: json['documentId'] as String,
      isVisible: json['isVisible'] as bool,
      isLocked: json['isLocked'] as bool,
      color: Color(json['color'] as int),
      opacity: json['opacity'] as double,
      annotations:
          (json['annotations'] as List)
              .map((a) => Annotation.fromJson(a as Map<String, dynamic>))
              .toList(),
    );
  }
}
