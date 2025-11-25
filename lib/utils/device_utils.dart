import 'dart:io';
import 'package:flutter/material.dart';

enum DeviceType {
  phone,
  tablet,
}

class DeviceUtils {
  /// Phân biệt device type dựa trên kích thước màn hình
  /// Tablet được định nghĩa là device có độ rộng nhỏ nhất >= 600dp
  static DeviceType getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    // Ngưỡng phân biệt tablet và phone (600dp là standard của Android)
    return shortestSide >= 600 ? DeviceType.tablet : DeviceType.phone;
  }

  /// Kiểm tra có phải tablet không
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Kiểm tra có phải phone không
  static bool isPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.phone;
  }

  /// Lấy tên device type
  static String getDeviceTypeName(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.tablet ? 'tablet' : 'phone';
  }

  /// Debug info về device
  static Map<String, dynamic> getDeviceInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceType = getDeviceType(context);

    return {
      'platform': Platform.operatingSystem,
      'isIOS': Platform.isIOS,
      'isAndroid': Platform.isAndroid,
      'width': size.width,
      'height': size.height,
      'shortestSide': size.shortestSide,
      'longestSide': size.longestSide,
      'deviceType': deviceType.name,
      'isTablet': deviceType == DeviceType.tablet,
      'isPhone': deviceType == DeviceType.phone,
    };
  }
}