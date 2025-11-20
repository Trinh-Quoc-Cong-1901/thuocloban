import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/logger_utils.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _cachePrefix = 'cache_';
  static const String _timestampSuffix = '_timestamp';

  /// Cache data with expiration time
  Future<bool> cacheData(
    String key,
    dynamic data, {
    int expirationHours = 24,
  }) async {
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = cacheKey + _timestampSuffix;

      // Store data
      final jsonData = jsonEncode(data);
      await _prefs.setString(cacheKey, jsonData);

      // Store timestamp
      final expirationTime = DateTime.now().add(
        Duration(hours: expirationHours),
      );
      await _prefs.setInt(timestampKey, expirationTime.millisecondsSinceEpoch);

      LoggerUtils.debug(
        'Cached data for key: $key (expires in ${expirationHours}h)',
      );
      return true;
    } catch (e) {
      LoggerUtils.error('Failed to cache data for key: $key', e);
      return false;
    }
  }

  /// Get cached data if not expired
  dynamic getCachedData(String key) {
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = cacheKey + _timestampSuffix;

      // Check if data exists
      if (!_prefs.containsKey(cacheKey) || !_prefs.containsKey(timestampKey)) {
        return null;
      }

      // Check expiration
      final expirationTime = _prefs.getInt(timestampKey);
      if (expirationTime == null) {
        return null;
      }

      final expiration = DateTime.fromMillisecondsSinceEpoch(expirationTime);
      if (DateTime.now().isAfter(expiration)) {
        // Data expired, remove it
        _removeCachedData(key);
        LoggerUtils.debug('Cache expired for key: $key');
        return null;
      }

      // Get and decode data
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson == null) {
        return null;
      }

      final data = jsonDecode(cachedJson);
      LoggerUtils.debug('Cache hit for key: $key');
      return data;
    } catch (e) {
      LoggerUtils.error('Failed to get cached data for key: $key', e);
      return null;
    }
  }

  /// Check if cache exists and is not expired
  bool hasCachedData(String key) {
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = cacheKey + _timestampSuffix;

      if (!_prefs.containsKey(cacheKey) || !_prefs.containsKey(timestampKey)) {
        return false;
      }

      final expirationTime = _prefs.getInt(timestampKey);
      if (expirationTime == null) {
        return false;
      }

      final expiration = DateTime.fromMillisecondsSinceEpoch(expirationTime);
      return DateTime.now().isBefore(expiration);
    } catch (e) {
      LoggerUtils.error('Failed to check cached data for key: $key', e);
      return false;
    }
  }

  /// Get cache expiration time
  DateTime? getCacheExpiration(String key) {
    try {
      final timestampKey = _cachePrefix + key + _timestampSuffix;
      final expirationTime = _prefs.getInt(timestampKey);

      if (expirationTime == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(expirationTime);
    } catch (e) {
      LoggerUtils.error('Failed to get cache expiration for key: $key', e);
      return null;
    }
  }

  /// Get time remaining until expiration
  Duration? getTimeUntilExpiration(String key) {
    final expiration = getCacheExpiration(key);
    if (expiration == null) {
      return null;
    }

    final now = DateTime.now();
    if (now.isAfter(expiration)) {
      return Duration.zero;
    }

    return expiration.difference(now);
  }

  /// Remove specific cached data
  Future<bool> removeCachedData(String key) async {
    return _removeCachedData(key);
  }

  Future<bool> _removeCachedData(String key) async {
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = cacheKey + _timestampSuffix;

      await _prefs.remove(cacheKey);
      await _prefs.remove(timestampKey);

      LoggerUtils.debug('Removed cached data for key: $key');
      return true;
    } catch (e) {
      LoggerUtils.error('Failed to remove cached data for key: $key', e);
      return false;
    }
  }

  /// Clear all cached data
  Future<bool> clearAllCachedData() async {
    try {
      final keys = _prefs.getKeys();
      final cacheKeys =
          keys.where((key) => key.startsWith(_cachePrefix)).toList();

      for (String key in cacheKeys) {
        await _prefs.remove(key);
      }

      LoggerUtils.debug(
        'Cleared all cached data (${cacheKeys.length} entries)',
      );
      return true;
    } catch (e) {
      LoggerUtils.error('Failed to clear all cached data', e);
      return false;
    }
  }

  /// Clear expired cache entries
  Future<int> clearExpiredCache() async {
    try {
      final keys = _prefs.getKeys();
      final timestampKeys =
          keys
              .where(
                (key) =>
                    key.startsWith(_cachePrefix) &&
                    key.endsWith(_timestampSuffix),
              )
              .toList();

      int clearedCount = 0;
      final now = DateTime.now();

      for (String timestampKey in timestampKeys) {
        final expirationTime = _prefs.getInt(timestampKey);
        if (expirationTime != null) {
          final expiration = DateTime.fromMillisecondsSinceEpoch(
            expirationTime,
          );
          if (now.isAfter(expiration)) {
            final baseKey = timestampKey
                .substring(_cachePrefix.length)
                .replaceAll(_timestampSuffix, '');

            await _removeCachedData(baseKey);
            clearedCount++;
          }
        }
      }

      LoggerUtils.debug('Cleared $clearedCount expired cache entries');
      return clearedCount;
    } catch (e) {
      LoggerUtils.error('Failed to clear expired cache', e);
      return 0;
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    try {
      final keys = _prefs.getKeys();
      final cacheKeys =
          keys
              .where(
                (key) =>
                    key.startsWith(_cachePrefix) &&
                    !key.endsWith(_timestampSuffix),
              )
              .toList();

      final timestampKeys =
          keys
              .where(
                (key) =>
                    key.startsWith(_cachePrefix) &&
                    key.endsWith(_timestampSuffix),
              )
              .toList();

      int totalSize = 0;
      int expiredCount = 0;
      final now = DateTime.now();

      for (String key in cacheKeys) {
        final data = _prefs.getString(key);
        if (data != null) {
          totalSize += data.length;
        }
      }

      for (String timestampKey in timestampKeys) {
        final expirationTime = _prefs.getInt(timestampKey);
        if (expirationTime != null) {
          final expiration = DateTime.fromMillisecondsSinceEpoch(
            expirationTime,
          );
          if (now.isAfter(expiration)) {
            expiredCount++;
          }
        }
      }

      return {
        'totalEntries': cacheKeys.length,
        'expiredEntries': expiredCount,
        'validEntries': cacheKeys.length - expiredCount,
        'totalSizeBytes': totalSize,
        'totalSizeKB': (totalSize / 1024).round(),
      };
    } catch (e) {
      LoggerUtils.error('Failed to get cache stats', e);
      return {
        'totalEntries': 0,
        'expiredEntries': 0,
        'validEntries': 0,
        'totalSizeBytes': 0,
        'totalSizeKB': 0,
      };
    }
  }

  /// Get all cache keys (without prefix)
  List<String> getAllCacheKeys() {
    try {
      final keys = _prefs.getKeys();
      return keys
          .where(
            (key) =>
                key.startsWith(_cachePrefix) && !key.endsWith(_timestampSuffix),
          )
          .map((key) => key.substring(_cachePrefix.length))
          .toList();
    } catch (e) {
      LoggerUtils.error('Failed to get cache keys', e);
      return [];
    }
  }

  /// Cache with custom TTL (time to live) in seconds
  Future<bool> cacheWithTTL(
    String key,
    dynamic data, {
    int ttlSeconds = 86400, // 24 hours default
  }) async {
    return cacheData(key, data, expirationHours: (ttlSeconds / 3600).ceil());
  }

  /// Cache temporarily (short-term cache)
  Future<bool> tempCache(
    String key,
    dynamic data, {
    int minutesTTL = 15,
  }) async {
    return cacheWithTTL(key, data, ttlSeconds: minutesTTL * 60);
  }

  /// Cache permanently (very long expiration)
  Future<bool> permanentCache(String key, dynamic data) async {
    return cacheData(key, data, expirationHours: 8760); // 1 year
  }

  /// Refresh cache with new data
  Future<bool> refreshCache(
    String key,
    dynamic newData, {
    int expirationHours = 24,
  }) async {
    await removeCachedData(key);
    return cacheData(key, newData, expirationHours: expirationHours);
  }
}
