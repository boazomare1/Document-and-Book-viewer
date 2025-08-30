import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Biometric types
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTypeKey = 'biometric_type';

  // Initialize biometric service
  Future<void> initialize() async {
    try {
      // Check if device supports biometric authentication
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticateWithBiometrics =
          await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !canAuthenticateWithBiometrics) {
        throw Exception(
          'Biometric authentication not supported on this device',
        );
      }
    } catch (e) {
      developer.log(
        'Failed to initialize biometric service: $e',
        name: 'BiometricService',
      );
    }
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticateWithBiometrics =
          await _localAuth.isDeviceSupported();

      return canCheckBiometrics && canAuthenticateWithBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics;
    } catch (e) {
      return [];
    }
  }

  // Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final String? enabled = await _secureStorage.read(
        key: _biometricEnabledKey,
      );
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  // Enable biometric authentication
  Future<void> enableBiometric() async {
    try {
      // First authenticate to enable biometric
      final bool authenticated = await authenticate(
        reason: 'Enable biometric authentication',
      );

      if (authenticated) {
        await _secureStorage.write(key: _biometricEnabledKey, value: 'true');

        // Store biometric type
        final List<BiometricType> availableBiometrics =
            await getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty) {
          await _secureStorage.write(
            key: _biometricTypeKey,
            value: availableBiometrics.first.toString(),
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to enable biometric authentication: $e');
    }
  }

  // Disable biometric authentication
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _biometricTypeKey);
    } catch (e) {
      throw Exception('Failed to disable biometric authentication: $e');
    }
  }

  // Authenticate using biometric
  Future<bool> authenticate({required String reason}) async {
    try {
      final bool isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return false;
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return authenticated;
    } catch (e) {
      developer.log(
        'Biometric authentication failed: $e',
        name: 'BiometricService',
      );
      return false;
    }
  }

  // Authenticate for PDF access
  Future<bool> authenticateForPdfAccess() async {
    return await authenticate(reason: 'Authenticate to access PDF');
  }

  // Authenticate for settings access
  Future<bool> authenticateForSettings() async {
    return await authenticate(reason: 'Authenticate to access settings');
  }

  // Authenticate for export access
  Future<bool> authenticateForExport() async {
    return await authenticate(reason: 'Authenticate to export data');
  }

  // Get biometric type string
  String getBiometricTypeString(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Touch ID';
      case BiometricType.iris:
        return 'Iris';
      default:
        return 'Biometric';
    }
  }

  // Get current biometric type
  Future<String?> getCurrentBiometricType() async {
    try {
      return await _secureStorage.read(key: _biometricTypeKey);
    } catch (e) {
      return null;
    }
  }

  // Check if device has strong biometric
  Future<bool> hasStrongBiometric() async {
    try {
      final List<BiometricType> availableBiometrics =
          await getAvailableBiometrics();

      return availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      return false;
    }
  }

  // Get authentication strength
  Future<AuthenticationStrength> getAuthenticationStrength() async {
    try {
      final List<BiometricType> availableBiometrics =
          await getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        return AuthenticationStrength.strong;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return AuthenticationStrength.strong;
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return AuthenticationStrength.strong;
      } else {
        return AuthenticationStrength.weak;
      }
    } catch (e) {
      return AuthenticationStrength.none;
    }
  }

  // Setup biometric authentication
  Future<bool> setupBiometric() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication not available');
      }

      final bool hasStrong = await hasStrongBiometric();
      if (!hasStrong) {
        throw Exception('Strong biometric authentication required');
      }

      await enableBiometric();
      return true;
    } catch (e) {
      developer.log('Failed to setup biometric: $e', name: 'BiometricService');
      return false;
    }
  }

  // Validate biometric setup
  Future<BiometricValidationResult> validateBiometricSetup() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricValidationResult(
          isValid: false,
          error: 'Biometric authentication not available on this device',
        );
      }

      final bool isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return BiometricValidationResult(
          isValid: false,
          error: 'Biometric authentication is not enabled',
        );
      }

      final bool hasStrong = await hasStrongBiometric();
      if (!hasStrong) {
        return BiometricValidationResult(
          isValid: false,
          error: 'Strong biometric authentication required',
        );
      }

      return BiometricValidationResult(isValid: true);
    } catch (e) {
      return BiometricValidationResult(
        isValid: false,
        error: 'Biometric validation failed: $e',
      );
    }
  }

  // Get biometric status
  Future<BiometricStatus> getBiometricStatus() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      final bool isEnabled = await isBiometricEnabled();
      final List<BiometricType> availableTypes = await getAvailableBiometrics();
      final String? currentType = await getCurrentBiometricType();

      return BiometricStatus(
        isAvailable: isAvailable,
        isEnabled: isEnabled,
        availableTypes: availableTypes,
        currentType: currentType,
      );
    } catch (e) {
      return BiometricStatus(
        isAvailable: false,
        isEnabled: false,
        availableTypes: [],
        currentType: null,
      );
    }
  }
}

enum AuthenticationStrength { none, weak, strong }

class BiometricValidationResult {
  final bool isValid;
  final String? error;

  const BiometricValidationResult({required this.isValid, this.error});
}

class BiometricStatus {
  final bool isAvailable;
  final bool isEnabled;
  final List<BiometricType> availableTypes;
  final String? currentType;

  const BiometricStatus({
    required this.isAvailable,
    required this.isEnabled,
    required this.availableTypes,
    this.currentType,
  });

  bool get hasStrongBiometric {
    return availableTypes.contains(BiometricType.face) ||
        availableTypes.contains(BiometricType.fingerprint);
  }

  String get statusDescription {
    if (!isAvailable) {
      return 'Biometric authentication not available';
    } else if (!isEnabled) {
      return 'Biometric authentication disabled';
    } else {
      return 'Biometric authentication enabled';
    }
  }
}
