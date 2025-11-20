import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/logger_utils.dart';

class DatabaseProvider {
  // Singleton pattern
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  factory DatabaseProvider() => _instance;
  DatabaseProvider._internal();

  bool _isInitialized = false;
  final Map<String, Box> _boxes = {};

  /// Mở một box với kiểu dữ liệu cụ thể <T>
  /// Thay đổi: Thêm tham số kiểu <T> và trả về Future<Box<T>>
  Future<Box<T>> openBox<T>(String boxName) async {
    if (!_isInitialized) {
      // Hive should already be initialized in main.dart via Hive.initFlutter()
      _isInitialized = true;
      LoggerUtils.debug(
        'DatabaseProvider marked as initialized - Hive.initFlutter() should have been called in main.dart',
      );
    }

    // Kiểm tra xem box đã mở và có đúng kiểu chưa
    if (_boxes.containsKey(boxName)) {
      final existingBox = _boxes[boxName];
      // Nếu box đã mở và đúng kiểu T thì trả về
      if (existingBox is Box<T>) {
        return existingBox;
      } else {
        // Nếu box đã mở nhưng sai kiểu, đóng box cũ và mở lại với kiểu mới
        LoggerUtils.warning(
          'Box $boxName was opened with a different type. Re-opening with type $T.',
        );
        await existingBox?.close(); // Đóng box cũ nếu đang mở
        _boxes.remove(boxName); // Xóa khỏi map quản lý
      }
    }

    try {
      // Mở box với kiểu dữ liệu T
      final box = await Hive.openBox<T>(boxName);
      _boxes[boxName] = box; // Lưu box đã mở vào map
      LoggerUtils.debug('Opened Hive box: $boxName with type $T');
      return box;
    } catch (e, stackTrace) {
      LoggerUtils.error(
        'Failed to open box: $boxName with type $T',
        e,
        stackTrace,
      );
      // Cân nhắc việc xử lý lỗi cụ thể hơn, ví dụ: xóa file box bị lỗi và thử lại
      // Hoặc throw lỗi để tầng gọi xử lý
      rethrow;
    }
  }

  /// Close a specific box
  Future<void> closeBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      await _boxes[boxName]!.close();
      _boxes.remove(boxName);
      LoggerUtils.debug('Closed box: $boxName');
    }
  }

  /// Close all open boxes
  Future<void> closeAllBoxes() async {
    // Sao chép danh sách keys để tránh lỗi thay đổi map khi đang duyệt
    final boxNames = _boxes.keys.toList();
    for (final boxName in boxNames) {
      await closeBox(boxName);
    }
    LoggerUtils.debug('Closed all boxes.');
  }

  /// Lấy giá trị từ một box với kiểu dữ liệu <T>
  /// Thay đổi: Sử dụng box đã được ép kiểu sẵn
  T? getValue<T>(String boxName, String key) {
    final box = _boxes[boxName];
    if (box == null) {
      LoggerUtils.warning('Box $boxName is not open or does not exist.');
      return null;
    }
    // Không cần ép kiểu ở đây nữa nếu box đã được mở đúng kiểu
    if (box is Box<T>) {
      return box.get(key);
    } else {
      // Nếu box không đúng kiểu (trường hợp hiếm), cố gắng đọc dynamic
      try {
        dynamic value = box.get(key);
        if (value is T) {
          return value;
        } else {
          LoggerUtils.warning(
            'Value for key $key in box $boxName is not of type $T.',
          );
          return null;
        }
      } catch (e) {
        LoggerUtils.error(
          'Error reading value for key $key in box $boxName',
          e,
        );
        return null;
      }
    }
  }

  /// Đặt giá trị vào một box với kiểu dữ liệu <T>
  /// Thay đổi: Mở box với kiểu dữ liệu <T> nếu chưa mở
  Future<void> putValue<T>(String boxName, String key, T value) async {
    // Mở box với kiểu T nếu chưa mở hoặc sai kiểu
    final Box<T> box = await openBox<T>(boxName);
    try {
      await box.put(key, value);
    } catch (e, stackTrace) {
      LoggerUtils.error(
        'Failed to put value for key $key in box $boxName',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Delete a value from a box
  Future<void> deleteValue(String boxName, String key) async {
    final box = _boxes[boxName];
    if (box == null) {
      LoggerUtils.warning('Box $boxName is not open for deletion.');
      return; // Hoặc mở box nếu muốn đảm bảo xóa được
      // await openBox(boxName); // Mở box nếu chưa tồn tại
      // box = _boxes[boxName];
      // if (box == null) return; // Vẫn có thể lỗi nếu mở không thành công
    }
    try {
      await box.delete(key);
    } catch (e, stackTrace) {
      LoggerUtils.error(
        'Failed to delete value for key $key in box $boxName',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Clear all values in a box
  Future<void> clearBox(String boxName) async {
    // Mở box nếu chưa mở
    final Box box = await openBox<dynamic>(boxName); // Mở dynamic để clear
    try {
      await box.clear();
      LoggerUtils.debug('Cleared box: $boxName');
    } catch (e, stackTrace) {
      LoggerUtils.error('Failed to clear box $boxName', e, stackTrace);
      rethrow;
    }
  }

  /// Check if a box contains a key
  bool containsKey(String boxName, String key) {
    final box = _boxes[boxName];
    if (box == null) {
      // LoggerUtils.warning('Box $boxName is not open to check key.');
      return false;
    }
    return box.containsKey(key);
  }

  // --- Các hàm xử lý JSON (Giữ nguyên hoặc có thể tối ưu bằng TypeAdapter) ---

  /// Store a JSON object (as String)
  Future<void> putJson(
    String boxName,
    String key,
    Map<String, dynamic> json,
  ) async {
    // Mở box String để lưu JSON
    final Box<String> box = await openBox<String>(boxName);
    await box.put(key, jsonEncode(json));
  }

  /// Get a JSON object (from String)
  Map<String, dynamic>? getJson(String boxName, String key) {
    // Mở box String để đọc JSON
    final box = _boxes[boxName];
    if (box == null || box is! Box<String>) {
      LoggerUtils.warning(
        'Box $boxName is not open or not of type String for getJson.',
      );
      return null;
    }

    final jsonString = (box as Box<String>).get(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      LoggerUtils.error(
        'Failed to decode JSON from box $boxName, key $key',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Store a list of JSON objects (as String)
  Future<void> putJsonList(
    String boxName,
    String key,
    List<Map<String, dynamic>> jsonList,
  ) async {
    // Mở box String để lưu JSON list
    final Box<String> box = await openBox<String>(boxName);
    await box.put(key, jsonEncode(jsonList));
  }

  /// Get a list of JSON objects (from String)
  List<Map<String, dynamic>>? getJsonList(String boxName, String key) {
    final box = _boxes[boxName];
    if (box == null || box is! Box<String>) {
      LoggerUtils.warning(
        'Box $boxName is not open or not of type String for getJsonList.',
      );
      return null;
    }

    final jsonString = (box as Box<String>).get(key);
    if (jsonString == null) return null;

    try {
      final decodedList = jsonDecode(jsonString) as List;
      // Đảm bảo mọi item trong list là Map<String, dynamic>
      return decodedList.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          // Cố gắng chuyển đổi nếu là Map<dynamic, dynamic>
          return Map<String, dynamic>.from(item);
        } else {
          throw const FormatException("Item in list is not a Map");
        }
      }).toList();
    } catch (e, stackTrace) {
      LoggerUtils.error(
        'Failed to decode JSON list from box $boxName, key $key',
        e,
        stackTrace,
      );
      return null;
    }
  }
}
