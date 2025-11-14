import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:thuoc_lo_ban_app/features/thuoc_lo_ban/bindings/thuoc_lo_ban_binding.dart';
import 'package:thuoc_lo_ban_app/features/thuoc_lo_ban/views/thuoc_lo_ban_screen.dart';
import 'package:thuoc_lo_ban_app/features/thuoc_lo_ban/views/guide_screen.dart';
import 'package:thuoc_lo_ban_app/features/chat/bindings/chat_binding.dart';
import 'package:thuoc_lo_ban_app/features/chat/views/chat_view.dart';
import 'package:thuoc_lo_ban_app/services/notification_service.dart';
import 'package:thuoc_lo_ban_app/services/chat_service.dart';
import 'firebase_options.dart';

// Handler cho notifications khi app bị terminate
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background notification: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive first for local storage
  await Hive.initFlutter();
  print('✅ Hive initialized successfully');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup Crashlytics để bắt tất cả lỗi Flutter
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Initialize ChatService globally to persist throughout app lifecycle
  Get.put<ChatService>(ChatService(), permanent: true);
  print('✅ ChatService registered globally - will auto-initialize via onInit()');

  // Gửi analytics event khi app khởi động
  FirebaseAnalytics.instance.logEvent(name: 'app_opened');

  // Chạy app trước
  runApp(const MyApp());

  // Khởi tạo notification service sau khi app đã hiển thị (không chặn UI)
  NotificationService.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Thước Lỗ Ban',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      initialRoute: '/thuoc-lo-ban',
      getPages: [
        GetPage(
          name: '/thuoc-lo-ban',
          page: () => const ThuocLoBanScreen(),
          binding: ThuocLoBanBinding(),
        ),
        GetPage(
          name: '/thuoc-lo-ban/guide',
          page: () => const GuideScreen(),
        ),
        GetPage(
          name: '/chat',
          page: () => const ChatView(),
          binding: ChatBinding(),
        ),
      ],
    );
  }
}