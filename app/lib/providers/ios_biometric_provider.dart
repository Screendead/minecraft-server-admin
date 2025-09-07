import 'package:flutter/foundation.dart';
import '../services/ios_biometric_encryption_service.dart';
import '../services/ios_secure_api_key_service.dart';
import '../services/api_key_migration_service.dart';

class IOSBiometricProvider extends ChangeNotifier {
  final IOSBiometricEncryptionService _biometricService;
  final IOSSecureApiKeyService _apiKeyService;
  final ApiKeyMigrationService _migrationService;
  
  bool _isInitialized = false;
  bool _isBiometricAvailable = false;
  bool _hasApiKey = false;
  bool _needsMigration = false;
  String? _errorMessage;

  IOSBiometricProvider({
    required IOSBiometricEncryptionService biometricService,
    required IOSSecureApiKeyService apiKeyService,
    required ApiKeyMigrationService migrationService,
  }) : _biometricService = biometricService,
        _apiKeyService = apiKeyService,
        _migrationService = migrationService {
    _init();
  }

  bool get isInitialized => _isInitialized;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get hasApiKey => _hasApiKey;
  bool get needsMigration => _needsMigration;
  String? get errorMessage => _errorMessage;

  Future<void> _init() async {
    try {
      _isBiometricAvailable = await _biometricService.isBiometricAvailable();
      _hasApiKey = await _apiKeyService.hasApiKey();
      
      final migrationStatus = await _migrationService.getMigrationStatus();
      _needsMigration = migrationStatus['needsMigration'] ?? false;
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize biometric services: $e';
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> refreshStatus() async {
    await _init();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
