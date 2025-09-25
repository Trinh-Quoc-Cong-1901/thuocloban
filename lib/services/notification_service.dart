import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/notification_model.dart';
import '../constants/notification_constants.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Store active notifications
  static List<NotificationModel> _activeNotifications = [];
  
  // Khởi tạo notifications
  static Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request permissions từ cả Local và Firebase
      await _requestAllPermissions();
      
      String? token;
      
      if (Platform.isIOS) {
        // Đợi APNS token với retry logic mạnh hơn
        String? apnsToken;
        int maxRetries = 10;
        int retryCount = 0;
        
        while (apnsToken == null && retryCount < maxRetries) {
          apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken == null) {
            print('APNS Token not available yet, retry ${retryCount + 1}/$maxRetries...');
            await Future.delayed(Duration(seconds: 2));
            retryCount++;
          } else {
            print('APNS Token: $apnsToken');
          }
        }
        
        if (apnsToken == null) {
          print('Failed to get APNS token after $maxRetries retries');
          // Vẫn thử lấy FCM token để tránh crash
          try {
            token = await _firebaseMessaging.getToken();
          } catch (e) {
            print('Failed to get FCM token: $e');
            // Vẫn setup local notifications dù Firebase fail
          }
        } else {
          // Lấy FCM token sau khi có APNS token
          token = await _firebaseMessaging.getToken();
        }
      } else {
        // Android - không cần APNS token
        token = await _firebaseMessaging.getToken();
      }
      
      print('FCM Token: $token');
      
      // Subscribe to topic để nhận notification từ server
      if (token != null) {
        await _firebaseMessaging.subscribeToTopic('daily_7_30');
        print('Subscribed to daily_7_30 topic');
      }
      
      // Setup FCM message handlers
      _setupFCMHandlers();
      
      // Setup all default notifications
      await _setupDefaultNotifications();
      
      // Auto-run diagnostics for debugging (only in debug mode)
      assert(() {
        print('\n🔍 === AUTO DIAGNOSTIC START ===');
        diagnoseFirebaseIssue();
        print('🔍 === AUTO DIAGNOSTIC END ===\n');
        return true;
      }());
      
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }
  
  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(initializationSettings);
  }
  
  // Request all permissions (Local + Firebase)
  static Future<bool> _requestAllPermissions() async {
    bool allGranted = true;
    
    // 1. Request Local Notification Permission
    if (Platform.isIOS) {
      final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final localPermission = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('Local notification permission: $localPermission');
        if (!localPermission!) allGranted = false;
      }
    } else if (Platform.isAndroid) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final localPermission = await androidPlugin.requestNotificationsPermission();
        print('Local notification permission: $localPermission');
        if (!localPermission!) allGranted = false;
      }
    }
    
    // 2. Request Firebase Permission
    NotificationSettings fcmSettings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false, // false = ask user explicitly
    );
    
    print('FCM Permission status: ${fcmSettings.authorizationStatus}');
    print('Alert setting: ${fcmSettings.alert}');
    print('Badge setting: ${fcmSettings.badge}');
    print('Sound setting: ${fcmSettings.sound}');
    
    if (fcmSettings.authorizationStatus != AuthorizationStatus.authorized) {
      print('❌ FCM Permission denied!');
      allGranted = false;
      
      // Show user-friendly message
      _showPermissionDeniedMessage();
    } else {
      print('✅ FCM Permission granted!');
    }
    
    return allGranted;
  }
  
  // Show permission denied message
  static void _showPermissionDeniedMessage() {
    print('🚨 User cần vào Settings > Notifications > App để bật thông báo!');
    // Em có thể show dialog hoặc snackbar ở đây
  }
  
  // Setup FCM message handlers
  static void _setupFCMHandlers() {
    // Handle foreground messages (khi app đang mở)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Foreground FCM message received!');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      
      // Show local notification cho foreground messages
      _showFCMAsLocalNotification(message);
    });
    
    // Handle notification tapped (khi user tap vào notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 FCM message opened app!');
      print('Title: ${message.notification?.title}');
      print('Data: ${message.data}');
      
      // Navigate to specific screen based on message data
      _handleNotificationTap(message);
    });
    
    // Check for initial message (khi app mở từ terminated state)
    _checkInitialMessage();
  }
  
  // Show FCM as local notification (for foreground messages)
  static Future<void> _showFCMAsLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_messages',
      'Firebase Messages',
      channelDescription: 'Messages received from Firebase',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode, // Unique ID based on message
      notification.title ?? 'Firebase Message',
      notification.body ?? 'New message received',
      notificationDetails,
      payload: message.data.toString(),
    );
  }
  
  // Handle notification tap navigation
  static void _handleNotificationTap(RemoteMessage message) {
    print('🔗 Handling notification tap...');
    print('Data: ${message.data}');
    
    // Example: Navigate based on message data
    final screen = message.data['screen'];
    if (screen != null) {
      print('Navigate to screen: $screen');
      // Get.toNamed('/screen-name'); // Uncomment if using GetX
    }
  }
  
  // Check for initial message when app starts
  static Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
    if (initialMessage != null) {
      print('📱 App opened from FCM notification!');
      _handleNotificationTap(initialMessage);
    }
  }
  
  // Setup all default notifications
  static Future<void> _setupDefaultNotifications() async {
    _activeNotifications = NotificationConstants.defaultNotifications;
    
    for (final notification in _activeNotifications) {
      if (notification.isEnabled) {
        await scheduleNotification(notification);
      }
    }
    
    print('Setup ${_activeNotifications.length} notifications');
  }
  
  // Schedule a single notification
  static Future<void> scheduleNotification(NotificationModel notification) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      notification.channelId,
      notification.channelName,
      channelDescription: 'Scheduled notification at ${notification.hour}:${notification.minute.toString().padLeft(2, '0')}',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Calculate next scheduled time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, 
      now.year, 
      now.month, 
      now.day, 
      notification.hour, 
      notification.minute
    );
    
    // If time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    print('Scheduling notification ${notification.id} at: $scheduledDate');
    
    await _localNotifications.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }
  
  // Add new custom notification
  static Future<void> addCustomNotification({
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? channelId,
    String? channelName,
  }) async {
    final newNotification = NotificationModel(
      id: NotificationConstants.getNextAvailableId(),
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      channelId: channelId ?? 'custom_reminders',
      channelName: channelName ?? 'Custom Reminders',
    );
    
    _activeNotifications.add(newNotification);
    await scheduleNotification(newNotification);
    
    print('Added custom notification: $newNotification');
  }
  
  // Enable/disable notification
  static Future<void> toggleNotification(int notificationId, bool enabled) async {
    final index = _activeNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _activeNotifications[index] = _activeNotifications[index].copyWith(isEnabled: enabled);
      
      if (enabled) {
        await scheduleNotification(_activeNotifications[index]);
        print('Enabled notification $notificationId');
      } else {
        await _localNotifications.cancel(notificationId);
        print('Disabled notification $notificationId');
      }
    }
  }
  
  // Remove notification
  static Future<void> removeNotification(int notificationId) async {
    await _localNotifications.cancel(notificationId);
    _activeNotifications.removeWhere((n) => n.id == notificationId);
    print('Removed notification $notificationId');
  }
  
  // Get all active notifications
  static List<NotificationModel> getActiveNotifications() {
    return _activeNotifications;
  }
  
  // Get pending notifications from system
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }
  
  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
  
  // Show immediate test notification
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      999,
      '🧪 Test Notification',
      'Notification system đang hoạt động tốt!',
      notificationDetails,
    );
  }
  
  // Debug: Check current permission status
  static Future<void> checkPermissionStatus() async {
    print('=== PERMISSION STATUS CHECK ===');
    
    // FCM Permission
    NotificationSettings fcmSettings = await _firebaseMessaging.getNotificationSettings();
    print('FCM Status: ${fcmSettings.authorizationStatus}');
    print('Alert: ${fcmSettings.alert}');
    print('Badge: ${fcmSettings.badge}');
    print('Sound: ${fcmSettings.sound}');
    
    // FCM Token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: ${token?.substring(0, 20)}...');
    
    // APNS Token (iOS only)
    if (Platform.isIOS) {
      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      print('APNS Token: ${apnsToken?.substring(0, 20)}...');
    }
    
    // Pending notifications
    final pending = await getPendingNotifications();
    print('Pending local notifications: ${pending.length}');
    for (final p in pending) {
      print('  - ID ${p.id}: ${p.title} at ${p.body}');
    }
    
    print('==============================');
  }
  
  // Debug: Test FCM với topic
  static Future<void> testFCMSubscription() async {
    try {
      print('🔍 Testing FCM subscription...');
      
      // Subscribe to test topic
      await _firebaseMessaging.subscribeToTopic('test_topic_debug');
      print('✅ Subscribed to test_topic_debug');
      
      // Also subscribe to a simple topic
      await _firebaseMessaging.subscribeToTopic('all_users');
      print('✅ Subscribed to all_users');
      
      print('📱 Topics ready for testing:');
      print('   - test_topic_debug');
      print('   - all_users');
      print('   - daily_7_30');
      
      print('🧪 Gửi test message từ Firebase Console với topic "test_topic_debug"');
    } catch (e) {
      print('❌ FCM subscription error: $e');
    }
  }
  
  // Force request FCM token again
  static Future<void> refreshFCMToken() async {
    try {
      print('🔄 Refreshing FCM token...');
      await _firebaseMessaging.deleteToken();
      await Future.delayed(Duration(seconds: 2));
      String? newToken = await _firebaseMessaging.getToken();
      print('🆕 New FCM Token: $newToken');
    } catch (e) {
      print('❌ Token refresh error: $e');
    }
  }
  
  // Manual test notification via FCM
  static Future<void> manualFCMTest() async {
    print('📱 Manual FCM Test - Check these steps:');
    print('1. Copy FCM Token from console');
    print('2. Go to Firebase Console > Messaging');
    print('3. Click "Send test message"');
    print('4. Paste FCM token');
    print('5. Send immediately');
    
    String? token = await _firebaseMessaging.getToken();
    print('📋 FCM Token to copy:');
    print(token);
    
    // iOS APNs debug
    if (Platform.isIOS) {
      print('🍎 iOS APNs Debug:');
      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      print('APNS Token available: ${apnsToken != null}');
      if (apnsToken != null) {
        print('APNS Token: ${apnsToken.substring(0, 20)}...');
      }
      
      print('⚠️  If FCM test fails:');
      print('   1. Check Firebase Console > Project Settings > Cloud Messaging');
      print('   2. iOS app configuration section');
      print('   3. Must have APNs Authentication Key or Certificate');
      print('   4. Without APNs key, iOS cannot receive FCM!');
    }
  }
  
  // Test specific to current issue
  static Future<void> diagnoseFirebaseIssue() async {
    print('🔍 DIAGNOSING FIREBASE ISSUE:');
    print('=====================================');
    
    // Platform info
    print('📱 Platform: ${Platform.operatingSystem}');
    print('📱 Is iOS: ${Platform.isIOS}');
    print('📱 Is Android: ${Platform.isAndroid}');
    
    // Check permissions
    NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
    print('🔐 Permission Status: ${settings.authorizationStatus}');
    print('🔐 Alert: ${settings.alert}');
    print('🔐 Badge: ${settings.badge}'); 
    print('🔐 Sound: ${settings.sound}');
    
    // Check tokens - only try if we have proper permissions
    String? fcmToken;
    try {
      fcmToken = await _firebaseMessaging.getToken();
      print('🎟️  FCM Token exists: ${fcmToken != null}');
      if (fcmToken != null) {
        print('🎟️  FCM Token: ${fcmToken.substring(0, 50)}...');
      } else {
        print('⚠️  FCM Token is NULL - may need Push Notifications capability');
      }
    } catch (e) {
      print('⚠️  Cannot get FCM token: $e');
      print('💡 This is normal if Push Notifications capability is disabled');
    }
    
    if (Platform.isIOS) {
      try {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        print('🍎 APNS Token exists: ${apnsToken != null}');
        if (apnsToken != null) {
          print('🍎 APNS Token: ${apnsToken.substring(0, 20)}...');
        } else {
          print('⚠️  APNS Token is NULL - normal without Push Notifications capability');
        }
      } catch (e) {
        print('⚠️  Cannot get APNS token: $e');
        print('💡 This is normal if Push Notifications capability is disabled');
      }
    }
    
    // Test local notifications work
    print('🧪 Testing local notification...');
    await showTestNotification();
    print('✅ Local test sent (should appear immediately)');
    
    // Final diagnosis
    print('=====================================');
    print('📊 DIAGNOSIS SUMMARY:');
    
    if (fcmToken == null) {
      print('🚨 CRITICAL: No FCM Token - FCM cannot work!');
    } else if (Platform.isIOS && settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('🚨 CRITICAL: iOS permission denied!');
    } else if (Platform.isIOS) {
      print('⚠️  LIKELY ISSUE: Missing APNs key in Firebase Console');
      print('   👉 Go to: Firebase Console > Project Settings > Cloud Messaging');
      print('   👉 Upload APNs Authentication Key (.p8 file) from Apple Developer');
      print('   👉 Or test on real iPhone device (not simulator)');
    } else {
      print('✅ Android setup looks good - FCM should work');
    }
    
    print('🎯 NEXT STEPS:');
    print('   1. Check if you see local notification popup');
    print('   2. Copy FCM token and test manual in Firebase Console');
    print('   3. Ensure running on real device (not simulator for iOS)');
    print('   4. Check APNs key in Firebase Console for iOS');
    print('=====================================');
  }
}