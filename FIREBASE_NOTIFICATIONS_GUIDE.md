# Hướng dẫn Firebase Push Notifications cho Flutter App

## Tổng quan
Guide này hướng dẫn từ A-Z cách setup và sử dụng Firebase Cloud Messaging (FCM) để gửi push notifications trong Flutter app. Dành cho người chưa biết gì về notifications.

---

## Push Notification là gì?

### Khái niệm cơ bản
**Push Notification** = Thông báo đẩy đến thiết bị user kể cả khi app không mở.

### Ví dụ thực tế:
- 📱 **Facebook:** "Bạn có tin nhắn mới"
- 🛒 **Shopee:** "Flash sale 12h - Giảm 50%"
- 📰 **VnExpress:** "Tin tức nóng hôm nay"
- 🎮 **Game:** "Năng lượng đã đầy, quay lại chơi!"

### Các loại notifications:

**1. Foreground (App đang mở):**
- Hiện trong app như dialog/banner
- User đang sử dụng app

**2. Background (App ở background):**
- Hiện trên notification bar
- User thấy notification, tap vào mở app

**3. Terminated (App đã tắt):**
- Hiện trên notification bar
- App khởi động khi user tap notification

---

## Firebase Cloud Messaging (FCM) hoạt động như thế nào?

### Sơ đồ hoạt động:
```
📱 Flutter App                🔥 Firebase Server               📱 User Device
      │                              │                              │
      │ 1. Đăng ký nhận notification │                              │
      ├─────────────────────────────→│                              │
      │                              │                              │
      │ 2. Nhận FCM Token            │                              │
      ├←─────────────────────────────│                              │
      │                              │                              │
                                     │ 3. Admin gửi notification    │
                                     │    từ Firebase Console       │
                                     │                              │
      │                              │ 4. Firebase đẩy notification │
      │                              ├─────────────────────────────→│
      │                              │                              │
      │ 5. User tap notification     │                              │
      ├←─────────────────────────────┼──────────────────────────────┤
      │                              │                              │
      │ 6. Xử lý trong app           │                              │
```

### Giải thích:
1. **App đăng ký** với FCM server
2. **Nhận token** (định danh duy nhất cho thiết bị)
3. **Admin/Backend** gửi notification qua Firebase Console
4. **Firebase server** đẩy đến thiết bị
5. **User** thấy và tap notification
6. **App** nhận và xử lý notification

---

## Bước 1: Prerequisites

### 1.1. Kiểm tra Firebase đã setup chưa
```bash
ls lib/firebase_options.dart
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist
```

**Nếu chưa có:** Làm theo guide `FIREBASE_SETUP.md` trước.

### 1.2. Kiểm tra app có chạy được không
```bash
flutter run
```

**Phải chạy được app trước khi làm notifications.**

---

## Bước 2: Thêm Firebase Messaging

### 2.1. Thêm dependency
```bash
flutter pub add firebase_messaging
```

### 2.2. Kiểm tra version trong pubspec.yaml
```yaml
dependencies:
  firebase_messaging: ^latest_version
```

### 2.3. Update dependencies
```bash
flutter pub get
```

---

## Bước 3: Setup Android

### 3.1. Thêm permissions vào AndroidManifest
**File:** `android/app/src/main/AndroidManifest.xml`

Thêm trước tag `<application>`:
```xml
<!-- Internet permission (đã có sẵn) -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Notification permissions -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Android 13+ notification permission -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 3.2. Thêm notification icon (Optional)
**Tạo file:** `android/app/src/main/res/drawable/ic_notification.png`
- Icon 24x24dp, màu trắng, nền trong suốt

**Nếu không có icon, Android sẽ dùng icon mặc định.**

---

## Bước 4: Setup iOS

### 4.1. Thêm capability trong Xcode
```bash
open ios/Runner.xcworkspace
```

**Trong Xcode:**
1. Chọn **Runner** project
2. Tab **Signing & Capabilities**
3. Click **+ Capability**
4. Thêm **Push Notifications**
5. Thêm **Background Modes**
   - Tick **Remote notifications**

### 4.2. Request notification permission trong iOS
iOS yêu cầu xin permission từ user trước khi nhận notifications.

---

## Bước 5: Code cơ bản - Khởi tạo FCM

### 5.1. Update main.dart
**File:** `lib/main.dart`

Thêm import:
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
```

### 5.2. Thêm global handler cho background notifications
**Thêm trước `main()` function:**

```dart
// Handler cho notifications khi app bị terminate
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background notification: ${message.messageId}');
}
```

### 5.3. Update main() function
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Firebase Analytics & Crashlytics (code cũ)
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  FirebaseAnalytics.instance.logEvent(name: 'app_opened');
  
  runApp(const MyApp());
}
```

---

## Bước 6: Tạo Notification Service

### 6.1. Tạo file service
**File:** `lib/services/notification_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Khởi tạo notifications
  static Future<void> initialize() async {
    // Request permission (iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      announcement: false,
    );
    
    print('Permission status: ${settings.authorizationStatus}');
    
    // Lấy FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // Setup handlers
    _setupHandlers();
  }
  
  // Setup các handlers cho notifications
  static void _setupHandlers() {
    // App đang mở (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground notification received!');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      
      // Hiển thị notification trong app
      _showForegroundNotification(message);
    });
    
    // User tap notification khi app ở background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped!');
      print('Data: ${message.data}');
      
      // Xử lý navigation hoặc action
      _handleNotificationTap(message);
    });
    
    // Check nếu app mở từ notification (terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state via notification');
        _handleNotificationTap(message);
      }
    });
  }
  
  // Hiển thị notification khi app đang mở
  static void _showForegroundNotification(RemoteMessage message) {
    // Có thể dùng package flutter_local_notifications
    // Hoặc hiển thị SnackBar, Dialog trong app
    print('Show in-app notification: ${message.notification?.title}');
  }
  
  // Xử lý khi user tap notification
  static void _handleNotificationTap(RemoteMessage message) {
    // Navigation logic
    print('Handle tap: ${message.data}');
    
    // Ví dụ: navigate to specific screen based on data
    if (message.data['screen'] == 'profile') {
      // Navigate to profile
    }
  }
  
  // Subscribe to topic (nhận notification theo chủ đề)
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }
  
  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}
```

### 6.2. Import service vào main.dart
```dart
import 'package:thuoc_lo_ban_app/services/notification_service.dart';
```

### 6.3. Khởi tạo service trong main()
**Update main() function:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Khởi tạo notification service
  await NotificationService.initialize();
  
  // Firebase Analytics & Crashlytics (code cũ)
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  FirebaseAnalytics.instance.logEvent(name: 'app_opened');
  
  runApp(const MyApp());
}
```

---

## Bước 7: Test cơ bản

### 7.1. Chạy app và lấy FCM token
```bash
flutter run
```

**Trong console sẽ thấy:**
```
FCM Token: [một chuỗi dài]
Permission status: AuthorizationStatus.authorized
```

**Copy FCM token này để test.**

### 7.2. Test notification từ Firebase Console

**1. Vào Firebase Console:**
- https://console.firebase.google.com/
- Chọn project của bạn

**2. Vào Cloud Messaging:**
- Menu bên trái > Engage > Messaging
- Click "Create your first campaign"
- Chọn "Firebase Notification messages"

**3. Compose notification:**
- **Notification title:** "Test Notification"  
- **Notification text:** "Hello from Firebase!"
- **Notification image:** (optional)

**4. Target:**
- Chọn "Single device"
- Paste FCM token đã copy ở bước 7.1

**5. Scheduling:**
- Chọn "Now"

**6. Additional options:**
- Custom data (optional): 
  - Key: "screen", Value: "home"

**7. Review và Send:**
- Click "Review" > "Publish"

### 7.3. Kiểm tra kết quả

**Case 1: App đang mở (foreground)**
- Console sẽ print: "Foreground notification received!"
- Không hiện notification bar (cần code thêm)

**Case 2: App ở background**  
- Hiện notification trên notification bar
- Tap vào sẽ mở app và print: "Notification tapped!"

**Case 3: App bị tắt (terminated)**
- Hiện notification trên notification bar
- Tap vào sẽ mở app và print: "App opened from terminated state"

---

## Bước 8: Cải thiện UX - Hiện notification trong app

### 8.1. Thêm flutter_local_notifications
```bash
flutter pub add flutter_local_notifications
```

### 8.2. Update notification service cho foreground notifications
**File:** `lib/services/notification_service.dart`

Thêm import:
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
```

Update NotificationService:
```dart
class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    // Setup local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    
    await _localNotifications.initialize(initializationSettings);
    
    // Existing Firebase setup code...
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      announcement: false,
    );
    
    print('Permission status: ${settings.authorizationStatus}');
    
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    _setupHandlers();
  }
  
  // Update foreground notification handler
  static void _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? 'You have a new message',
      details,
    );
  }
}
```

---

## Bước 9: Navigation từ Notifications

### 9.1. Setup navigation context
**File:** `lib/main.dart`

Tạo global navigation key:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey, // Thêm dòng này
      title: 'Thước Lỗ Ban',
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
      ],
    );
  }
}
```

### 9.2. Update notification handler với navigation
**File:** `lib/services/notification_service.dart`

```dart
import 'package:get/get.dart';

class NotificationService {
  // Existing code...
  
  static void _handleNotificationTap(RemoteMessage message) {
    print('Handle tap: ${message.data}');
    
    // Navigation logic based on notification data
    String? screen = message.data['screen'];
    
    switch (screen) {
      case 'guide':
        Get.toNamed('/thuoc-lo-ban/guide');
        break;
      case 'home':
        Get.toNamed('/thuoc-lo-ban');
        break;
      default:
        // Default action
        Get.toNamed('/thuoc-lo-ban');
    }
  }
}
```

---

## Bước 10: Topic-based Notifications

### 10.1. Subscribe to topics trong app
**Example usage:**
```dart
// Subscribe to "news" topic
await NotificationService.subscribeToTopic('news');

// Subscribe to "promotions" topic  
await NotificationService.subscribeToTopic('promotions');
```

### 10.2. Test topic notifications từ Firebase Console

**1. Compose notification như bước 7.2**

**2. Target:**
- Chọn "Topic" thay vì "Single device"
- Nhập topic name: "news"

**3. Send notification**

**Kết quả:** Tất cả devices subscribe topic "news" sẽ nhận notification.

---

## Bước 11: Advanced Features

### 11.1. Notification với images
**Trong Firebase Console:**
- Thêm "Notification image" URL khi compose
- Android sẽ hiện big picture notification

### 11.2. Custom actions
**Thêm custom data:**
- Key: "action", Value: "open_calculator"  
- Key: "screen", Value: "thuoc-lo-ban"

**Handle trong code:**
```dart
static void _handleNotificationTap(RemoteMessage message) {
  String? action = message.data['action'];
  
  switch (action) {
    case 'open_calculator':
      Get.toNamed('/thuoc-lo-ban');
      // Do specific calculator action
      break;
    // Other actions...
  }
}
```

### 11.3. Scheduled notifications
Dùng server/backend hoặc Firebase Functions để gửi notifications theo schedule.

---

## Troubleshooting

### Lỗi thường gặp

**1. Không nhận được notifications:**
```bash
# Check FCM token
flutter logs | grep "FCM Token"

# Check permissions
flutter logs | grep "Permission status"
```

**2. iOS không hiện notification permission dialog:**
- Check iOS deployment target >= 10.0
- Restart app sau khi thêm Push Notifications capability

**3. Android không hiện notifications:**
- Check `POST_NOTIFICATIONS` permission trong AndroidManifest
- Check notification channel setup (Android 8+)

**4. Background notifications không hoạt động:**
- Check background handler function có `@pragma('vm:entry-point')`
- Check app có bị kill bởi battery optimization không

### Debug commands
```bash
# Xem full logs
flutter logs

# Test trên specific device  
flutter run -d [device-id]

# Build release để test production behavior
flutter build apk --release
```

---

## Kết quả cuối cùng

Sau khi hoàn thành, bạn sẽ có:

✅ **Push notifications hoạt động** trên Android & iOS  
✅ **Foreground notifications** hiển thị trong app  
✅ **Background/terminated notifications** trên system bar  
✅ **Navigation** từ notifications đến screens cụ thể  
✅ **Topic-based messaging** cho user groups  
✅ **FCM token** để target specific devices  

### Files được tạo/cập nhật:
- `lib/services/notification_service.dart` (mới)
- `lib/main.dart` (updated)
- `android/app/src/main/AndroidManifest.xml` (updated)
- iOS Push Notifications capability (trong Xcode)

### Dependencies thêm vào:
```yaml
dependencies:
  firebase_messaging: ^latest
  flutter_local_notifications: ^latest
```

---

## Sơ đồ tổng quan Notifications

```
📱 Setup Notifications
│
├── 🔧 BƯỚC 1-2: Prerequisites & Add Package
│   ├── ✅ Firebase đã setup
│   └── 📦 firebase_messaging
│
├── ⚙️ BƯỚC 3-4: Platform Setup  
│   ├── 🤖 Android permissions + icon
│   └── 🍎 iOS capabilities + permissions
│
├── 💻 BƯỚC 5-6: Code Implementation
│   ├── 🚀 Background handler
│   ├── 🔧 NotificationService class
│   └── 🔗 Initialize in main()
│
├── ✅ BƯỚC 7: Basic Testing
│   ├── 📝 Get FCM token  
│   └── 🔥 Send from Firebase Console
│
├── 🎨 BƯỚC 8-9: UX Improvements
│   ├── 📱 Local notifications for foreground
│   └── 🧭 Navigation from notifications
│
├── 📢 BƯỚC 10-11: Advanced Features
│   ├── 🏷️ Topic-based messaging
│   ├── 🖼️ Rich media notifications
│   └── ⚡ Custom actions
│
└── 🎯 KẾT QUẢ:
    ├── 📨 Nhận notifications mọi lúc
    ├── 🧭 Navigation đến đúng màn hình
    ├── 🏷️ Group messaging với topics
    └── 🚀 Production ready notifications!
```

**Firebase Notifications setup hoàn tất! 🔔🎉**

### Workflow thực tế:
```
Setup → Add Package → Platform Config → Code Service → Test → Enhance UX → Advanced Features → Deploy
  ↓         ↓             ↓            ↓        ↓       ↓           ↓              ↓
5 phút   5 phút      10-15 phút   15-20 phút  10 phút  15 phút    10 phút       ∞
```

**Tổng thời gian: ~1-2 giờ** (tùy iOS setup complexity)