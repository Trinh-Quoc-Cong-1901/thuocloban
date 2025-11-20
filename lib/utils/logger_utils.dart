import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/env_config.dart';

/// A utility class for logging messages in the application.
///
/// This class provides static methods for logging messages with different
/// levels of severity (debug, info, warning, error).
class LoggerUtils {
  /// The logger instance used internally.
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print emojis
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Show timestamp
    ),
    // Only log in debug mode or when explicitly enabled
    level: kDebugMode || !EnvConfig.isProduction ? Level.warning : Level.error,
  );

  /// Logs a debug message.
  ///
  /// Use this for detailed information, typically of interest only when
  /// diagnosing problems.
  ///
  /// ```dart
  /// LoggerUtils.debug('This is a debug message');
  /// ```
  static void debug(dynamic message) {
    if (kDebugMode || !EnvConfig.isProduction) {
      _logger.d(message);
    }
  }

  /// Logs an info message.
  ///
  /// Use this for informational messages that highlight the progress of the
  /// application at a coarse-grained level.
  ///
  /// ```dart
  /// LoggerUtils.info('User logged in successfully');
  /// ```
  static void info(dynamic message) {
    _logger.i(message);
  }

  /// Logs a warning message.
  ///
  /// Use this for potentially harmful situations that don't prevent the
  /// application from working.
  ///
  /// ```dart
  /// LoggerUtils.warning('API rate limit reached, retrying in 5 seconds');
  /// ```
  static void warning(dynamic message) {
    _logger.w(message);
  }

  /// Logs an error message.
  ///
  /// Use this for error events that might still allow the application to
  /// continue running.
  ///
  /// ```dart
  /// try {
  ///   // some code that might throw an exception
  /// } catch (e, stackTrace) {
  ///   LoggerUtils.error('An error occurred', e, stackTrace);
  /// }
  /// ```
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Gửi lỗi không nghiêm trọng (non-fatal) lên Crashlytics nếu có thể
    try {
      if (EnvConfig.enableCrashlytics && error != null) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: message?.toString(),
        );
      }
    } catch (crashlyticsError) {
      // Không làm gì nếu Crashlytics chưa được khởi tạo hoặc có lỗi
      if (kDebugMode) {
        print('Failed to send error to Crashlytics: $crashlyticsError');
      }
    }
  }

  /// Logs a fatal error message.
  ///
  /// Use this for severe error events that will likely lead to application
  /// failure.
  ///
  /// ```dart
  /// LoggerUtils.fatal('Critical database connection error');
  /// ```
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    // Gửi lỗi nghiêm trọng (fatal) lên Crashlytics nếu có thể
    try {
      if (EnvConfig.enableCrashlytics && error != null) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: message?.toString(),
          fatal: true,
        );
      }
    } catch (crashlyticsError) {
      // Không làm gì nếu Crashlytics chưa được khởi tạo hoặc có lỗi
      if (kDebugMode) {
        print('Failed to send fatal error to Crashlytics: $crashlyticsError');
      }
    }
  }

  /// Clears the logger's output
  static void clear() {
    // This is just a placeholder as Logger doesn't have a built-in clear method
    debug('Logger cleared');
  }
}
