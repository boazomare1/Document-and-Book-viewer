import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/annotation.dart';
import '../models/pdf_document.dart';
import 'package:uuid/uuid.dart';

class CollaborationService {
  static final CollaborationService _instance =
      CollaborationService._internal();
  factory CollaborationService() => _instance;
  CollaborationService._internal();

  final Uuid _uuid = const Uuid();
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _sessionId;
  String? _userId;

  // Collaboration settings
  bool _enableRealTimeSync = true;
  bool _enableAnnotationSharing = true;
  bool _enableExportSummaries = true;

  // Callbacks for real-time updates
  Function(List<Annotation>)? _onAnnotationsUpdated;
  Function(String)? _onUserJoined;
  Function(String)? _onUserLeft;
  Function(String)? _onMessageReceived;

  // Initialize collaboration service
  Future<void> initialize() async {
    try {
      // Load collaboration settings
      await _loadSettings();
    } catch (e) {
      print('Failed to initialize collaboration service: $e');
    }
  }

  // Connect to collaboration server
  Future<bool> connectToServer(String serverUrl, String userId) async {
    try {
      _userId = userId;
      _sessionId = _uuid.v4();

      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

      // Send connection message
      await _sendMessage({
        'type': 'connect',
        'userId': userId,
        'sessionId': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Listen for messages
      _channel!.stream.listen(
        (message) => _handleIncomingMessage(message),
        onError: (error) => _handleConnectionError(error),
        onDone: () => _handleConnectionClosed(),
      );

      _isConnected = true;
      return true;
    } catch (e) {
      print('Failed to connect to collaboration server: $e');
      return false;
    }
  }

  // Disconnect from server
  Future<void> disconnect() async {
    try {
      if (_channel != null) {
        await _sendMessage({
          'type': 'disconnect',
          'userId': _userId,
          'sessionId': _sessionId,
          'timestamp': DateTime.now().toIso8601String(),
        });

        await _channel!.sink.close();
        _channel = null;
      }

      _isConnected = false;
      _sessionId = null;
    } catch (e) {
      print('Failed to disconnect: $e');
    }
  }

  // Share annotations with other users
  Future<bool> shareAnnotations(
    String documentId,
    List<Annotation> annotations,
  ) async {
    try {
      if (!_isConnected || !_enableAnnotationSharing) {
        return false;
      }

      await _sendMessage({
        'type': 'share_annotations',
        'userId': _userId,
        'sessionId': _sessionId,
        'documentId': documentId,
        'annotations': annotations.map((a) => a.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Failed to share annotations: $e');
      return false;
    }
  }

  // Sync annotations in real-time
  Future<bool> syncAnnotations(
    String documentId,
    List<Annotation> annotations,
  ) async {
    try {
      if (!_isConnected || !_enableRealTimeSync) {
        return false;
      }

      await _sendMessage({
        'type': 'sync_annotations',
        'userId': _userId,
        'sessionId': _sessionId,
        'documentId': documentId,
        'annotations': annotations.map((a) => a.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Failed to sync annotations: $e');
      return false;
    }
  }

  // Export annotations as summary
  Future<String> exportAnnotationSummary(
    String documentId,
    List<Annotation> annotations,
  ) async {
    try {
      if (!_enableExportSummaries) {
        throw Exception('Export summaries is disabled');
      }

      final Map<String, dynamic> summary = {
        'documentId': documentId,
        'exportDate': DateTime.now().toIso8601String(),
        'totalAnnotations': annotations.length,
        'annotationTypes': _getAnnotationTypeCounts(annotations),
        'annotations': annotations.map((a) => a.toJson()).toList(),
        'summary': _generateAnnotationSummary(annotations),
      };

      final String summaryJson = json.encode(summary);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'annotation_summary_${documentId}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File(path.join(directory.path, fileName));
      await file.writeAsString(summaryJson);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export annotation summary: $e');
    }
  }

  // Share annotated PDF
  Future<String> shareAnnotatedPdf(
    String pdfPath,
    List<Annotation> annotations,
  ) async {
    try {
      // In a real implementation, you would:
      // 1. Load the original PDF
      // 2. Apply annotations to the PDF
      // 3. Save as a new annotated PDF
      // 4. Return the path to the annotated PDF

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'annotated_${path.basename(pdfPath)}';
      final annotatedPath = path.join(directory.path, fileName);

      // For now, just copy the original file
      await File(pdfPath).copy(annotatedPath);

      return annotatedPath;
    } catch (e) {
      throw Exception('Failed to share annotated PDF: $e');
    }
  }

  // Join collaboration session
  Future<bool> joinSession(String sessionId) async {
    try {
      if (!_isConnected) {
        return false;
      }

      await _sendMessage({
        'type': 'join_session',
        'userId': _userId,
        'sessionId': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Failed to join session: $e');
      return false;
    }
  }

  // Leave collaboration session
  Future<bool> leaveSession() async {
    try {
      if (!_isConnected) {
        return false;
      }

      await _sendMessage({
        'type': 'leave_session',
        'userId': _userId,
        'sessionId': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Failed to leave session: $e');
      return false;
    }
  }

  // Send chat message
  Future<bool> sendChatMessage(String message) async {
    try {
      if (!_isConnected) {
        return false;
      }

      await _sendMessage({
        'type': 'chat_message',
        'userId': _userId,
        'sessionId': _sessionId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Failed to send chat message: $e');
      return false;
    }
  }

  // Set callbacks for real-time updates
  void setCallbacks({
    Function(List<Annotation>)? onAnnotationsUpdated,
    Function(String)? onUserJoined,
    Function(String)? onUserLeft,
    Function(String)? onMessageReceived,
  }) {
    _onAnnotationsUpdated = onAnnotationsUpdated;
    _onUserJoined = onUserJoined;
    _onUserLeft = onUserLeft;
    _onMessageReceived = onMessageReceived;
  }

  // Handle incoming messages
  void _handleIncomingMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = json.decode(message.toString());
      final String type = data['type'];

      switch (type) {
        case 'annotations_updated':
          _handleAnnotationsUpdated(data);
          break;
        case 'user_joined':
          _handleUserJoined(data);
          break;
        case 'user_left':
          _handleUserLeft(data);
          break;
        case 'chat_message':
          _handleChatMessage(data);
          break;
        default:
          print('Unknown message type: $type');
      }
    } catch (e) {
      print('Failed to handle incoming message: $e');
    }
  }

  // Handle annotations updated
  void _handleAnnotationsUpdated(Map<String, dynamic> data) {
    try {
      final List<dynamic> annotationsData = data['annotations'];
      final List<Annotation> annotations =
          annotationsData.map((a) => Annotation.fromJson(a)).toList();

      _onAnnotationsUpdated?.call(annotations);
    } catch (e) {
      print('Failed to handle annotations updated: $e');
    }
  }

  // Handle user joined
  void _handleUserJoined(Map<String, dynamic> data) {
    final String userId = data['userId'];
    _onUserJoined?.call(userId);
  }

  // Handle user left
  void _handleUserLeft(Map<String, dynamic> data) {
    final String userId = data['userId'];
    _onUserLeft?.call(userId);
  }

  // Handle chat message
  void _handleChatMessage(Map<String, dynamic> data) {
    final String message = data['message'];
    _onMessageReceived?.call(message);
  }

  // Handle connection error
  void _handleConnectionError(error) {
    print('WebSocket connection error: $error');
    _isConnected = false;
  }

  // Handle connection closed
  void _handleConnectionClosed() {
    print('WebSocket connection closed');
    _isConnected = false;
  }

  // Send message to server
  Future<void> _sendMessage(Map<String, dynamic> message) async {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }

  // Get annotation type counts
  Map<String, int> _getAnnotationTypeCounts(List<Annotation> annotations) {
    final Map<String, int> counts = {};

    for (final annotation in annotations) {
      final String type = annotation.type.toString();
      counts[type] = (counts[type] ?? 0) + 1;
    }

    return counts;
  }

  // Generate annotation summary
  String _generateAnnotationSummary(List<Annotation> annotations) {
    if (annotations.isEmpty) {
      return 'No annotations found.';
    }

    final Map<String, int> typeCounts = _getAnnotationTypeCounts(annotations);
    final List<String> summaryParts = [];

    typeCounts.forEach((type, count) {
      summaryParts.add('$count ${type.toLowerCase()} annotations');
    });

    return 'Document contains ${annotations.length} total annotations: ${summaryParts.join(', ')}.';
  }

  // Load collaboration settings
  Future<void> _loadSettings() async {
    // In a real implementation, you would load from secure storage
    _enableRealTimeSync = true;
    _enableAnnotationSharing = true;
    _enableExportSummaries = true;
  }

  // Save collaboration settings
  Future<void> _saveSettings() async {
    // In a real implementation, you would save to secure storage
  }

  // Update collaboration settings
  Future<void> updateSettings({
    bool? enableRealTimeSync,
    bool? enableAnnotationSharing,
    bool? enableExportSummaries,
  }) async {
    if (enableRealTimeSync != null) _enableRealTimeSync = enableRealTimeSync;
    if (enableAnnotationSharing != null)
      _enableAnnotationSharing = enableAnnotationSharing;
    if (enableExportSummaries != null)
      _enableExportSummaries = enableExportSummaries;

    await _saveSettings();
  }

  // Get collaboration status
  CollaborationStatus getStatus() {
    return CollaborationStatus(
      isConnected: _isConnected,
      sessionId: _sessionId,
      userId: _userId,
      enableRealTimeSync: _enableRealTimeSync,
      enableAnnotationSharing: _enableAnnotationSharing,
      enableExportSummaries: _enableExportSummaries,
    );
  }

  // Check if connected
  bool get isConnected => _isConnected;

  // Get session ID
  String? get sessionId => _sessionId;

  // Get user ID
  String? get userId => _userId;
}

class CollaborationStatus {
  final bool isConnected;
  final String? sessionId;
  final String? userId;
  final bool enableRealTimeSync;
  final bool enableAnnotationSharing;
  final bool enableExportSummaries;

  const CollaborationStatus({
    required this.isConnected,
    this.sessionId,
    this.userId,
    required this.enableRealTimeSync,
    required this.enableAnnotationSharing,
    required this.enableExportSummaries,
  });

  String get statusDescription {
    if (!isConnected) {
      return 'Disconnected';
    } else if (sessionId != null) {
      return 'Connected to session: ${sessionId!.substring(0, 8)}...';
    } else {
      return 'Connected';
    }
  }
}
