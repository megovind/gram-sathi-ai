import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class StorageService extends ChangeNotifier {
  // Non-sensitive — SharedPreferences is fine
  static const _keyUserId = 'userId';
  static const _keyLanguage = 'language';
  static const _keyOnboardingDone = 'onboardingDone';
  static const _keyShopId = 'shopId';
  static const _keyLastSearchedPincode = 'lastSearchedPincode';

  // Sensitive — stored in OS Keychain / Keystore via flutter_secure_storage
  static const _secKeyToken = 'authToken';
  static const _secKeyPhone = 'phone';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  // In-memory cache so secure reads stay synchronous after init
  String? _cachedToken;
  String? _cachedPhone;
  // Language cache so selected language is used immediately and after rebuilds
  String? _cachedLanguage;

  StorageService._(this._prefs, this._secure, this._cachedToken, this._cachedPhone, this._cachedLanguage);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    const secure = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final token = await secure.read(key: _secKeyToken);
    final phone = await secure.read(key: _secKeyPhone);
    final cachedLanguage = prefs.getString(_keyLanguage);
    return StorageService._(prefs, secure, token, phone, cachedLanguage);
  }

  // ── User identity ─────────────────────────────────────────

  String get userId {
    var id = _prefs.getString(_keyUserId);
    if (id == null) {
      id = const Uuid().v4();
      _prefs.setString(_keyUserId, id);
    }
    return id;
  }

  Future<void> setUserId(String id) => _prefs.setString(_keyUserId, id);

  // Phone is PII — kept in secure storage
  String? get phone => _cachedPhone;

  Future<void> setPhone(String p) async {
    _cachedPhone = p;
    await _secure.write(key: _secKeyPhone, value: p);
  }

  // ── Auth token ────────────────────────────────────────────

  String? get token => _cachedToken;

  Future<void> setToken(String t) async {
    _cachedToken = t;
    await _secure.write(key: _secKeyToken, value: t);
  }

  /// Returns true only if a token exists AND has not expired.
  bool get isLoggedIn {
    final t = _cachedToken;
    if (t == null || t.isEmpty) return false;
    try {
      final parts = t.split('.');
      if (parts.length != 3) return false;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final exp = data['exp'] as int?;
      if (exp == null) return false;
      return exp > DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      return false;
    }
  }

  // ── Language ──────────────────────────────────────────────

  /// Current language. Uses in-memory cache first so selection applies immediately.
  String get language => _cachedLanguage ?? _prefs.getString(_keyLanguage) ?? 'hi';

  Future<void> setLanguage(String code) async {
    if (_cachedLanguage != code) {
      _cachedLanguage = code;
      notifyListeners();
    }
    await _prefs.setString(_keyLanguage, code);
  }

  // ── Onboarding ────────────────────────────────────────────

  bool get onboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;

  Future<void> completeOnboarding() => _prefs.setBool(_keyOnboardingDone, true);

  // ── Location (for nearby screens) ─────────────────────────────

  String? get lastSearchedPincode => _prefs.getString(_keyLastSearchedPincode);

  Future<void> setLastSearchedPincode(String pincode) =>
      _prefs.setString(_keyLastSearchedPincode, pincode);

  // ── Shop owner ────────────────────────────────────────────

  String? get shopId => _prefs.getString(_keyShopId);

  Future<void> setShopId(String id) => _prefs.setString(_keyShopId, id);

  // ── Logout ────────────────────────────────────────────────

  Future<void> clear() async {
    _cachedToken = null;
    _cachedPhone = null;
    _cachedLanguage = null;
    await _secure.deleteAll();
    await _prefs.clear();
  }
}
