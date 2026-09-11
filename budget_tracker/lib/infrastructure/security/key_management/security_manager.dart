import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Central point for anything key- or credential-related. Backed by
/// flutter_secure_storage, which uses Keychain on iOS and Keystore
/// (hardware-backed where available) on Android — see PRD section 11.
class SecurityManager {
  SecurityManager({FlutterSecureStorage? storage, LocalAuthentication? localAuth})
      : _storage = storage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  static const _dbKeyIdentifier = 'db_encryption_key_v1';
  static const _pinHashIdentifier = 'pin_hash_v1';
  static const _pinSaltIdentifier = 'pin_salt_v1';

  /// Returns the SQLCipher passphrase, generating and persisting a new
  /// cryptographically random one on first launch. The key never leaves
  /// secure storage in plaintext form and is never logged.
  Future<String> getOrCreateDatabaseKey() async {
    final existing = await _storage.read(key: _dbKeyIdentifier);
    if (existing != null) return existing;

    final generated = generateEncryptionKey();
    await storeKey(generated, _dbKeyIdentifier);
    return generated;
  }

  String generateEncryptionKey({int lengthBytes = 32}) {
    final random = Random.secure();
    final bytes = List<int>.generate(lengthBytes, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  Future<void> storeKey(String key, String identifier) async {
    await _storage.write(key: identifier, value: key);
  }

  Future<String?> retrieveKey(String identifier) async {
    return _storage.read(key: identifier);
  }

  Future<void> deleteKey(String identifier) async {
    await _storage.delete(key: identifier);
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics({String reason = 'Unlock Budget Tracker'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }

  /// Sets up (or replaces) the app-lock PIN. Only a salted hash is ever
  /// persisted — the plaintext PIN is discarded immediately after hashing.
  Future<void> setPIN(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPIN(pin, salt);
    await _storage.write(key: _pinSaltIdentifier, value: salt);
    await _storage.write(key: _pinHashIdentifier, value: hash);
  }

  Future<bool> verifyPIN(String pin) async {
    final salt = await _storage.read(key: _pinSaltIdentifier);
    final storedHash = await _storage.read(key: _pinHashIdentifier);
    if (salt == null || storedHash == null) return false;
    return _hashPIN(pin, salt) == storedHash;
  }

  Future<bool> hasPINConfigured() async {
    return (await _storage.read(key: _pinHashIdentifier)) != null;
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPIN(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }
}
