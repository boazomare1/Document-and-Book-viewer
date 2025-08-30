import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/pdf_document.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Map<String, String> _fileHashes = {};
  final Map<String, DateTime> _scanTimestamps = {};

  // Security settings
  bool _enableFileValidation = true;
  bool _enableMalwareScanning = true;
  bool _enableEncryption = false;
  int _maxFileSize = 500 * 1024 * 1024; // 500MB

  // Initialize security service
  Future<void> initialize() async {
    try {
      // Load security settings from secure storage
      final enableValidation = await _secureStorage.read(
        key: 'security_enable_validation',
      );
      final enableScanning = await _secureStorage.read(
        key: 'security_enable_scanning',
      );
      final enableEncryption = await _secureStorage.read(
        key: 'security_enable_encryption',
      );
      final maxFileSize = await _secureStorage.read(
        key: 'security_max_file_size',
      );

      _enableFileValidation = enableValidation != 'false';
      _enableMalwareScanning = enableScanning != 'false';
      _enableEncryption = enableEncryption == 'true';
      _maxFileSize =
          maxFileSize != null ? int.parse(maxFileSize) : 500 * 1024 * 1024;
    } catch (e) {
      print('Failed to initialize security service: $e');
    }
  }

  // Validate PDF file
  Future<SecurityValidationResult> validatePdfFile(String filePath) async {
    try {
      final List<String> errors = [];
      final List<String> warnings = [];
      final List<String> info = [];

      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        errors.add('File does not exist');
        return SecurityValidationResult(
          isValid: false,
          errors: errors,
          warnings: warnings,
          info: info,
        );
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > _maxFileSize) {
        errors.add(
          'File size exceeds maximum allowed size (${_maxFileSize ~/ (1024 * 1024)}MB)',
        );
      }

      // Check file extension
      final extension = path.extension(filePath).toLowerCase();
      if (extension != '.pdf') {
        errors.add('File is not a valid PDF');
      }

      // Validate PDF header
      if (_enableFileValidation) {
        final isValidPdf = await _validatePdfHeader(filePath);
        if (!isValidPdf) {
          errors.add('Invalid PDF file format');
        }
      }

      // Check file hash
      final fileHash = await _calculateFileHash(filePath);
      if (_fileHashes.containsKey(filePath)) {
        final storedHash = _fileHashes[filePath];
        if (fileHash != storedHash) {
          warnings.add('File has been modified since last scan');
        }
      }
      _fileHashes[filePath] = fileHash;

      // Malware scanning (placeholder)
      if (_enableMalwareScanning) {
        final isSafe = await _scanForMalware(filePath);
        if (!isSafe) {
          errors.add('File failed security scan');
        }
      }

      // Check for embedded scripts
      final hasScripts = await _checkForEmbeddedScripts(filePath);
      if (hasScripts) {
        warnings.add('PDF contains embedded JavaScript');
      }

      // Check for external links
      final hasExternalLinks = await _checkForExternalLinks(filePath);
      if (hasExternalLinks) {
        warnings.add('PDF contains external links');
      }

      info.add('File size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)}MB');
      info.add('File hash: ${fileHash.substring(0, 16)}...');

      return SecurityValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        info: info,
      );
    } catch (e) {
      return SecurityValidationResult(
        isValid: false,
        errors: ['Validation failed: $e'],
        warnings: [],
        info: [],
      );
    }
  }

  // Validate PDF header
  Future<bool> _validatePdfHeader(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.openRead(0, 8).first;
      final header = utf8.decode(bytes);

      // Check for PDF magic number
      return header.startsWith('%PDF-');
    } catch (e) {
      return false;
    }
  }

  // Calculate file hash
  Future<String> _calculateFileHash(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  // Scan for malware (placeholder)
  Future<bool> _scanForMalware(String filePath) async {
    try {
      // In a real implementation, you would:
      // 1. Use a malware scanning library
      // 2. Check against known malware signatures
      // 3. Perform behavioral analysis

      // For now, return true (safe)
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check for embedded scripts
  Future<bool> _checkForEmbeddedScripts(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      // Look for JavaScript patterns
      final jsPatterns = ['/JS', '/JavaScript', 'script', 'javascript:'];

      for (final pattern in jsPatterns) {
        if (content.toLowerCase().contains(pattern.toLowerCase())) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Check for external links
  Future<bool> _checkForExternalLinks(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      // Look for URL patterns
      final urlPatterns = ['http://', 'https://', 'ftp://', 'mailto:'];

      for (final pattern in urlPatterns) {
        if (content.toLowerCase().contains(pattern.toLowerCase())) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Encrypt PDF file
  Future<String> encryptPdfFile(String filePath, String password) async {
    try {
      if (!_enableEncryption) {
        throw Exception('Encryption is disabled');
      }

      // In a real implementation, you would:
      // 1. Load the PDF document
      // 2. Apply encryption with the provided password
      // 3. Save the encrypted PDF

      final tempDir = await getTemporaryDirectory();
      final encryptedPath = path.join(
        tempDir.path,
        'encrypted_${path.basename(filePath)}',
      );

      // For now, just copy the file
      await File(filePath).copy(encryptedPath);

      // Store encryption info securely
      await _secureStorage.write(
        key: 'encrypted_${path.basename(filePath)}',
        value: json.encode({
          'originalPath': filePath,
          'encryptedPath': encryptedPath,
          'encryptedAt': DateTime.now().toIso8601String(),
        }),
      );

      return encryptedPath;
    } catch (e) {
      throw Exception('Failed to encrypt PDF: $e');
    }
  }

  // Decrypt PDF file
  Future<String> decryptPdfFile(String filePath, String password) async {
    try {
      if (!_enableEncryption) {
        throw Exception('Encryption is disabled');
      }

      // In a real implementation, you would:
      // 1. Load the encrypted PDF document
      // 2. Decrypt using the provided password
      // 3. Save the decrypted PDF

      final tempDir = await getTemporaryDirectory();
      final decryptedPath = path.join(
        tempDir.path,
        'decrypted_${path.basename(filePath)}',
      );

      // For now, just copy the file
      await File(filePath).copy(decryptedPath);

      return decryptedPath;
    } catch (e) {
      throw Exception('Failed to decrypt PDF: $e');
    }
  }

  // Sanitize PDF file
  Future<String> sanitizePdfFile(String filePath) async {
    try {
      // In a real implementation, you would:
      // 1. Load the PDF document
      // 2. Remove potentially dangerous content
      // 3. Strip embedded scripts
      // 4. Remove external links
      // 5. Save the sanitized PDF

      final tempDir = await getTemporaryDirectory();
      final sanitizedPath = path.join(
        tempDir.path,
        'sanitized_${path.basename(filePath)}',
      );

      // For now, just copy the file
      await File(filePath).copy(sanitizedPath);

      return sanitizedPath;
    } catch (e) {
      throw Exception('Failed to sanitize PDF: $e');
    }
  }

  // Get security settings
  Map<String, dynamic> getSecuritySettings() {
    return {
      'enableFileValidation': _enableFileValidation,
      'enableMalwareScanning': _enableMalwareScanning,
      'enableEncryption': _enableEncryption,
      'maxFileSize': _maxFileSize,
    };
  }

  // Update security settings
  Future<void> updateSecuritySettings({
    bool? enableFileValidation,
    bool? enableMalwareScanning,
    bool? enableEncryption,
    int? maxFileSize,
  }) async {
    try {
      if (enableFileValidation != null) {
        _enableFileValidation = enableFileValidation;
        await _secureStorage.write(
          key: 'security_enable_validation',
          value: enableFileValidation.toString(),
        );
      }

      if (enableMalwareScanning != null) {
        _enableMalwareScanning = enableMalwareScanning;
        await _secureStorage.write(
          key: 'security_enable_scanning',
          value: enableMalwareScanning.toString(),
        );
      }

      if (enableEncryption != null) {
        _enableEncryption = enableEncryption;
        await _secureStorage.write(
          key: 'security_enable_encryption',
          value: enableEncryption.toString(),
        );
      }

      if (maxFileSize != null) {
        _maxFileSize = maxFileSize;
        await _secureStorage.write(
          key: 'security_max_file_size',
          value: maxFileSize.toString(),
        );
      }
    } catch (e) {
      print('Failed to update security settings: $e');
    }
  }

  // Get file security info
  Map<String, dynamic> getFileSecurityInfo(String filePath) {
    final hash = _fileHashes[filePath];
    final scanTime = _scanTimestamps[filePath];

    return {
      'fileHash': hash,
      'lastScanned': scanTime?.toIso8601String(),
      'isValidated': hash != null,
    };
  }

  // Clear security cache
  void clearSecurityCache() {
    _fileHashes.clear();
    _scanTimestamps.clear();
  }

  // Check if file is trusted
  bool isFileTrusted(String filePath) {
    return _fileHashes.containsKey(filePath) &&
        _scanTimestamps.containsKey(filePath);
  }

  // Add file to trusted list
  void addToTrustedList(String filePath) {
    if (!_fileHashes.containsKey(filePath)) {
      _calculateFileHash(filePath).then((hash) {
        _fileHashes[filePath] = hash;
        _scanTimestamps[filePath] = DateTime.now();
      });
    }
  }

  // Remove file from trusted list
  void removeFromTrustedList(String filePath) {
    _fileHashes.remove(filePath);
    _scanTimestamps.remove(filePath);
  }
}

class SecurityValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final List<String> info;

  const SecurityValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.info,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasInfo => info.isNotEmpty;

  String get summary {
    if (isValid) {
      if (warnings.isNotEmpty) {
        return 'Valid with warnings';
      }
      return 'Valid';
    }
    return 'Invalid';
  }
}
