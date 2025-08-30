import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/pdf_document.dart';

enum CloudProvider { googleDrive, dropbox, onedrive }

class CloudStorageService {
  static final CloudStorageService _instance = CloudStorageService._internal();
  factory CloudStorageService() => _instance;
  CloudStorageService._internal();

  // Google Drive configuration
  String? _googleDriveAccessToken;
  String? _googleDriveRefreshToken;
  String _googleDriveApiUrl = 'https://www.googleapis.com/drive/v3';
  String _googleDriveUploadUrl = 'https://www.googleapis.com/upload/drive/v3';

  // Service status
  bool _isInitialized = false;
  CloudProvider? _activeProvider;

  // Initialize the service
  Future<void> initialize({
    CloudProvider provider = CloudProvider.googleDrive,
    String? accessToken,
    String? refreshToken,
  }) async {
    _activeProvider = provider;

    switch (provider) {
      case CloudProvider.googleDrive:
        _googleDriveAccessToken = accessToken;
        _googleDriveRefreshToken = refreshToken;
        break;
      case CloudProvider.dropbox:
        // TODO: Implement Dropbox authentication
        break;
      case CloudProvider.onedrive:
        // TODO: Implement OneDrive authentication
        break;
    }

    _isInitialized = true;
  }

  // Check if service is available
  bool get isAvailable => _isInitialized && _activeProvider != null;

  // Check if authenticated
  bool get isAuthenticated {
    switch (_activeProvider) {
      case CloudProvider.googleDrive:
        return _googleDriveAccessToken != null;
      case CloudProvider.dropbox:
        return false; // TODO: Implement
      case CloudProvider.onedrive:
        return false; // TODO: Implement
      default:
        return false;
    }
  }

  // Upload PDF to cloud storage
  Future<String> uploadPdf(String localPath, String fileName) async {
    if (!isAvailable || !isAuthenticated) {
      throw Exception('Cloud storage not available or not authenticated');
    }

    switch (_activeProvider) {
      case CloudProvider.googleDrive:
        return await _uploadToGoogleDrive(localPath, fileName);
      case CloudProvider.dropbox:
        throw UnimplementedError('Dropbox upload not yet implemented');
      case CloudProvider.onedrive:
        throw UnimplementedError('OneDrive upload not yet implemented');
      default:
        throw Exception('No cloud provider selected');
    }
  }

  // Download PDF from cloud storage
  Future<String> downloadPdf(String cloudFileId, String localFileName) async {
    if (!isAvailable || !isAuthenticated) {
      throw Exception('Cloud storage not available or not authenticated');
    }

    switch (_activeProvider) {
      case CloudProvider.googleDrive:
        return await _downloadFromGoogleDrive(cloudFileId, localFileName);
      case CloudProvider.dropbox:
        throw UnimplementedError('Dropbox download not yet implemented');
      case CloudProvider.onedrive:
        throw UnimplementedError('OneDrive download not yet implemented');
      default:
        throw Exception('No cloud provider selected');
    }
  }

  // List PDF files from cloud storage
  Future<List<CloudFile>> listPdfFiles() async {
    if (!isAvailable || !isAuthenticated) {
      throw Exception('Cloud storage not available or not authenticated');
    }

    switch (_activeProvider) {
      case CloudProvider.googleDrive:
        return await _listGoogleDrivePdfs();
      case CloudProvider.dropbox:
        throw UnimplementedError('Dropbox listing not yet implemented');
      case CloudProvider.onedrive:
        throw UnimplementedError('OneDrive listing not yet implemented');
      default:
        throw Exception('No cloud provider selected');
    }
  }

  // Delete PDF from cloud storage
  Future<void> deletePdf(String cloudFileId) async {
    if (!isAvailable || !isAuthenticated) {
      throw Exception('Cloud storage not available or not authenticated');
    }

    switch (_activeProvider) {
      case CloudProvider.googleDrive:
        await _deleteFromGoogleDrive(cloudFileId);
        break;
      case CloudProvider.dropbox:
        throw UnimplementedError('Dropbox delete not yet implemented');
      case CloudProvider.onedrive:
        throw UnimplementedError('OneDrive delete not yet implemented');
      default:
        throw Exception('No cloud provider selected');
    }
  }

  // Google Drive specific methods
  Future<String> _uploadToGoogleDrive(String localPath, String fileName) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        throw Exception('Local file not found: $localPath');
      }

      final url = Uri.parse(
        '$_googleDriveUploadUrl/files?uploadType=multipart',
      );

      final boundary =
          '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';

      final multipartRequest =
          http.MultipartRequest('POST', url)
            ..headers['Authorization'] = 'Bearer $_googleDriveAccessToken'
            ..headers['Content-Type'] = 'multipart/related; boundary=$boundary';

      // Add metadata part
      final metadata = {'name': fileName, 'mimeType': 'application/pdf'};

      multipartRequest.fields['metadata'] = json.encode(metadata);

      // Add file part
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
      );

      multipartRequest.files.add(multipartFile);

      final response = await multipartRequest.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        return responseData['id'] as String;
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload to Google Drive: $e');
    }
  }

  Future<String> _downloadFromGoogleDrive(
    String fileId,
    String localFileName,
  ) async {
    try {
      final url = Uri.parse('$_googleDriveApiUrl/files/$fileId?alt=media');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_googleDriveAccessToken'},
      );

      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final localPath = path.join(appDir.path, localFileName);

        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);

        return localPath;
      } else {
        throw Exception(
          'Download failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to download from Google Drive: $e');
    }
  }

  Future<List<CloudFile>> _listGoogleDrivePdfs() async {
    try {
      final url = Uri.parse(
        '$_googleDriveApiUrl/files?q=mimeType%3D%27application%2Fpdf%27&fields=files(id,name,size,modifiedTime,webViewLink)',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_googleDriveAccessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = data['files'] as List;

        return files
            .map(
              (file) => CloudFile(
                id: file['id'],
                name: file['name'],
                size: file['size'] != null ? int.parse(file['size']) : 0,
                modifiedTime: DateTime.parse(file['modifiedTime']),
                webViewLink: file['webViewLink'],
                provider: CloudProvider.googleDrive,
              ),
            )
            .toList();
      } else {
        throw Exception(
          'List failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to list Google Drive files: $e');
    }
  }

  Future<void> _deleteFromGoogleDrive(String fileId) async {
    try {
      final url = Uri.parse('$_googleDriveApiUrl/files/$fileId');

      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $_googleDriveAccessToken'},
      );

      if (response.statusCode != 204) {
        throw Exception(
          'Delete failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete from Google Drive: $e');
    }
  }

  // Refresh Google Drive access token
  Future<void> refreshGoogleDriveToken() async {
    if (_googleDriveRefreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final url = Uri.parse('https://oauth2.googleapis.com/token');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': 'YOUR_CLIENT_ID', // TODO: Add to configuration
          'client_secret': 'YOUR_CLIENT_SECRET', // TODO: Add to configuration
          'refresh_token': _googleDriveRefreshToken!,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _googleDriveAccessToken = data['access_token'];
      } else {
        throw Exception(
          'Token refresh failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  // Get authentication URL for Google Drive
  String getGoogleDriveAuthUrl() {
    const clientId = 'YOUR_CLIENT_ID'; // TODO: Add to configuration
    const redirectUri = 'com.example.pdfreader:/oauth2redirect';
    const scope = 'https://www.googleapis.com/auth/drive.file';

    return 'https://accounts.google.com/o/oauth2/v2/auth?'
        'client_id=$clientId&'
        'redirect_uri=$redirectUri&'
        'scope=$scope&'
        'response_type=code&'
        'access_type=offline';
  }

  // Handle OAuth callback
  Future<void> handleGoogleDriveCallback(String authorizationCode) async {
    try {
      const clientId = 'YOUR_CLIENT_ID'; // TODO: Add to configuration
      const clientSecret = 'YOUR_CLIENT_SECRET'; // TODO: Add to configuration
      const redirectUri = 'com.example.pdfreader:/oauth2redirect';

      final url = Uri.parse('https://oauth2.googleapis.com/token');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': authorizationCode,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _googleDriveAccessToken = data['access_token'];
        _googleDriveRefreshToken = data['refresh_token'];
      } else {
        throw Exception(
          'OAuth callback failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to handle OAuth callback: $e');
    }
  }

  // Get current status
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'activeProvider': _activeProvider?.toString(),
      'isAuthenticated': isAuthenticated,
      'hasAccessToken': _googleDriveAccessToken != null,
      'hasRefreshToken': _googleDriveRefreshToken != null,
    };
  }

  // Clear authentication
  void clearAuthentication() {
    _googleDriveAccessToken = null;
    _googleDriveRefreshToken = null;
  }
}

class CloudFile {
  final String id;
  final String name;
  final int size;
  final DateTime modifiedTime;
  final String? webViewLink;
  final CloudProvider provider;

  const CloudFile({
    required this.id,
    required this.name,
    required this.size,
    required this.modifiedTime,
    this.webViewLink,
    required this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'modifiedTime': modifiedTime.toIso8601String(),
      'webViewLink': webViewLink,
      'provider': provider.index,
    };
  }

  factory CloudFile.fromJson(Map<String, dynamic> json) {
    return CloudFile(
      id: json['id'],
      name: json['name'],
      size: json['size'],
      modifiedTime: DateTime.parse(json['modifiedTime']),
      webViewLink: json['webViewLink'],
      provider: CloudProvider.values[json['provider']],
    );
  }
}
