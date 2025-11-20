import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/logger_utils.dart';

class StorageProvider {
  static final StorageProvider _instance = StorageProvider._internal();
  factory StorageProvider() => _instance;
  StorageProvider._internal();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Basic storage operations
  Future<bool> write(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      LoggerUtils.error('Failed to write to storage: $key', e);
      return false;
    }
  }

  String? read(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      LoggerUtils.error('Failed to read from storage: $key', e);
      return null;
    }
  }

  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      LoggerUtils.error('Failed to remove from storage: $key', e);
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      LoggerUtils.error('Failed to clear storage', e);
      return false;
    }
  }

  // Type-specific operations
  Future<bool> writeInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      LoggerUtils.error('Failed to write int to storage: $key', e);
      return false;
    }
  }

  int? readInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      LoggerUtils.error('Failed to read int from storage: $key', e);
      return null;
    }
  }

  Future<bool> writeBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      LoggerUtils.error('Failed to write bool to storage: $key', e);
      return false;
    }
  }

  bool? readBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      LoggerUtils.error('Failed to read bool from storage: $key', e);
      return null;
    }
  }

  Future<bool> writeDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      LoggerUtils.error('Failed to write double to storage: $key', e);
      return false;
    }
  }

  double? readDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      LoggerUtils.error('Failed to read double from storage: $key', e);
      return null;
    }
  }

  Future<bool> writeStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      LoggerUtils.error('Failed to write string list to storage: $key', e);
      return false;
    }
  }

  List<String>? readStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      LoggerUtils.error('Failed to read string list from storage: $key', e);
      return null;
    }
  }

  // JSON operations
  Future<bool> writeJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await write(key, jsonString);
    } catch (e) {
      LoggerUtils.error('Failed to write JSON to storage: $key', e);
      return false;
    }
  }

  Map<String, dynamic>? readJson(String key) {
    try {
      final jsonString = read(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      LoggerUtils.error('Failed to read JSON from storage: $key', e);
      return null;
    }
  }

  // Authentication related methods
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  String? getToken() => read(_tokenKey);
  Future<bool> setToken(String token) => write(_tokenKey, token);
  Future<bool> clearToken() => remove(_tokenKey);

  String? getUserId() => read(_userIdKey);
  Future<bool> setUserId(String userId) => write(_userIdKey, userId);
  Future<bool> clearUserId() => remove(_userIdKey);

  bool isLoggedIn() => readBool(_isLoggedInKey) ?? false;
  Future<bool> setLoggedIn(bool value) => writeBool(_isLoggedInKey, value);

  // Settings related methods
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  String getTheme() => read(_themeKey) ?? 'light';
  Future<bool> setTheme(String theme) => write(_themeKey, theme);

  String getLanguage() => read(_languageKey) ?? 'vi';
  Future<bool> setLanguage(String language) => write(_languageKey, language);

  bool areNotificationsEnabled() => readBool(_notificationsEnabledKey) ?? true;
  Future<bool> setNotificationsEnabled(bool enabled) =>
      writeBool(_notificationsEnabledKey, enabled);

  // User preferences
  static const String _userPreferencesKey = 'user_preferences';

  Map<String, dynamic> getUserPreferences() =>
      readJson(_userPreferencesKey) ?? {};

  Future<bool> setUserPreferences(Map<String, dynamic> preferences) =>
      writeJson(_userPreferencesKey, preferences);

  // User profile storage
  static const String _userFullNameKey = 'user_full_name';
  static const String _userBirthDateKey = 'user_birth_date';
  static const String _isUserProfileCompleteKey = 'is_user_profile_complete';
  static const String _hasCalculationResultKey = 'has_calculation_result';

  // User profile methods
  String? getUserFullName() => read(_userFullNameKey);
  Future<bool> setUserFullName(String fullName) =>
      write(_userFullNameKey, fullName);

  String? getUserBirthDate() => read(_userBirthDateKey);
  Future<bool> setUserBirthDate(String birthDate) =>
      write(_userBirthDateKey, birthDate);

  bool isUserProfileComplete() => readBool(_isUserProfileCompleteKey) ?? false;
  Future<bool> setUserProfileComplete(bool value) =>
      writeBool(_isUserProfileCompleteKey, value);

  bool hasCalculationResult() => readBool(_hasCalculationResultKey) ?? false;
  Future<bool> setHasCalculationResult(bool value) =>
      writeBool(_hasCalculationResultKey, value);

  // Save complete user profile
  Future<bool> saveUserProfile({
    required String fullName,
    required String birthDate,
  }) async {
    try {
      await setUserFullName(fullName);
      await setUserBirthDate(birthDate);
      await setUserProfileComplete(true);
      return true;
    } catch (e) {
      LoggerUtils.error('Failed to save user profile', e);
      return false;
    }
  }

  // Clear user profile
  Future<bool> clearUserProfile() async {
    try {
      await remove(_userFullNameKey);
      await remove(_userBirthDateKey);
      await setUserProfileComplete(false);
      await setHasCalculationResult(false);
      return true;
    } catch (e) {
      LoggerUtils.error('Failed to clear user profile', e);
      return false;
    }
  }

  // Numerology specific storage
  static const String _numerologyHistoryKey = 'numerology_history';
  static const String _lastCalculationKey = 'last_calculation';

  List<String> getNumerologyHistory() =>
      readStringList(_numerologyHistoryKey) ?? [];
  Future<bool> setNumerologyHistory(List<String> history) =>
      writeStringList(_numerologyHistoryKey, history);

  Map<String, dynamic>? getLastCalculation() => readJson(_lastCalculationKey);
  Future<bool> setLastCalculation(Map<String, dynamic> calculation) =>
      writeJson(_lastCalculationKey, calculation);

  // Last viewed profile storage
  static const String _lastViewedProfileKey = 'last_viewed_profile';

  Map<String, dynamic>? getLastViewedProfile() =>
      readJson(_lastViewedProfileKey);
  Future<bool> setLastViewedProfile(Map<String, dynamic> profileData) =>
      writeJson(_lastViewedProfileKey, profileData);
  Future<bool> clearLastViewedProfile() => remove(_lastViewedProfileKey);

  // App state
  static const String _firstRunKey = 'is_first_run';
  static const String _lastVersionKey = 'last_app_version';

  bool isFirstRun() => readBool(_firstRunKey) ?? true;
  Future<bool> setFirstRun(bool value) => writeBool(_firstRunKey, value);

  String? getLastVersion() => read(_lastVersionKey);
  Future<bool> setLastVersion(String version) =>
      write(_lastVersionKey, version);

  // Check if key exists
  bool containsKey(String key) => _prefs.containsKey(key);

  // Get all keys
  Set<String> getKeys() => _prefs.getKeys();

  // User profiles management
  static const String _userProfilesKey = 'user_profiles';

  String? getUserProfiles() => read(_userProfilesKey);
  Future<bool> saveUserProfiles(String profilesJson) =>
      write(_userProfilesKey, profilesJson);

  // Get storage size (approximate)
  int getStorageSize() {
    int size = 0;
    for (String key in _prefs.getKeys()) {
      final value = _prefs.get(key);
      if (value is String) {
        size += value.length * 2; // UTF-16 encoding
      } else {
        size += 8; // Approximate size for other types
      }
    }
    return size;
  }

  // Clear specific category
  Future<bool> clearUserData() async {
    try {
      final keys = [_tokenKey, _userIdKey, _isLoggedInKey, _userPreferencesKey];
      for (String key in keys) {
        await remove(key);
      }
      return true;
    } catch (e) {
      LoggerUtils.error('Failed to clear user data', e);
      return false;
    }
  }

  Future<bool> clearNumerologyData() async {
    try {
      final keys = [_numerologyHistoryKey, _lastCalculationKey];
      for (String key in keys) {
        await remove(key);
      }
      return true;
    } catch (e) {
      LoggerUtils.error('Failed to clear numerology data', e);
      return false;
    }
  }
}
