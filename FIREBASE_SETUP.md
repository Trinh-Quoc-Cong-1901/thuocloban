# Hướng dẫn Setup Firebase cho Flutter App

## Tổng quan
Guide này hướng dẫn setup Firebase với Analytics, Crashlytics và Firestore Database cho Flutter app. Dựa trên kinh nghiệm thực tế với project Thước Lỗ Ban.

---

## Bước 1: Cài đặt Prerequisites

### 1.1. Kiểm tra Node.js
```bash
node --version
npm --version
```
**Nếu chưa có:** Tải từ https://nodejs.org/ (chọn phiên bản LTS)

### 1.2. Kiểm tra Firebase CLI
```bash
firebase --version
```
**Nếu chưa có:**
```bash
npm install -g firebase-tools
```

### 1.3. Cài đặt FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

**Nếu gặp lỗi dependency conflicts:**
```bash
dart pub global deactivate flutterfire_cli
dart pub global activate flutterfire_cli
```

### 1.4. Kiểm tra cài đặt
```bash
firebase --version      # Hiển thị version Firebase CLI
flutterfire --version   # Hiển thị version FlutterFire CLI
```

---

## Bước 2: Setup Firebase Project

### 2.1. Đăng nhập Firebase
```bash
firebase login
```
**Lưu ý:** Nếu đã đăng nhập trước đó sẽ hiển thị "Already logged in as..."

### 2.2. Tạo Firebase Project
**Cách 1 - CLI:**
```bash
firebase projects:create your-project-id
```

**Cách 2 - Web Console (Khuyến nghị):**
1. Vào https://console.firebase.google.com/
2. Click "Create a project"
3. Nhập tên project
4. Chọn region (asia-southeast1 cho Việt Nam)
5. Kích hoạt Google Analytics (khuyến nghị)

---

## Bước 3: Kết nối Flutter App với Firebase

### 3.1. Chạy FlutterFire Configure
```bash
cd your_flutter_project
flutterfire configure
```

**Quá trình:**
1. Chọn Firebase project
2. Chọn platforms (Android, iOS khuyến nghị)
3. Xác nhận package names

**Kết quả:**
- Tạo `lib/firebase_options.dart`
- Download `android/app/google-services.json`
- Download `ios/Runner/GoogleService-Info.plist`

### 3.2. Thêm Firebase Core
```bash
flutter pub add firebase_core
```

---

## Bước 4: Setup Firebase Services

### 4.1. Thêm Analytics & Crashlytics
```bash
flutter pub add firebase_analytics
flutter pub add firebase_crashlytics
```

### 4.2. Setup Firestore (nếu cần database)
```bash
flutter pub add cloud_firestore
```

**Trên Firebase Console:**
1. Firestore Database > Create database
2. Chọn "Start in test mode"
3. Chọn region

---

## Bước 5: Cập nhật Code

### 5.1. Import packages vào main.dart
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
```

### 5.2. Khởi tạo Firebase trong main()
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // Log app opened event
  FirebaseAnalytics.instance.logEvent(name: 'app_opened');
  
  runApp(MyApp());
}
```

### 5.3. Thêm Screen Tracking (cho GetX)
**Trong GetMaterialApp:**
```dart
GetMaterialApp(
  navigatorObservers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  // ... các config khác
)
```

---

## Bước 6: Xử lý iOS Issues

### 6.1. Fix iOS Deployment Target
**Nếu gặp lỗi iOS deployment target:**

**Cách 1 - Sửa Podfile:**
```bash
echo "platform :ios, '13.0'" > ios/Podfile
cd ios && pod install && cd ..
```

**Cách 2 - Downgrade Firebase Core:**
```yaml
# Trong pubspec.yaml
firebase_core: ^2.15.1  # Thay vì version mới nhất
```

### 6.2. Clean & Rebuild iOS
```bash
flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter pub get
```

---

## Bước 7: Test Setup

### 7.1. Test cơ bản
```bash
flutter run
```

### 7.2. Test trên Web (nếu cần)
```bash
flutterfire configure  # Thêm web platform
flutter run -d chrome
```

### 7.3. Kiểm tra Firebase Console
**Sau vài phút chạy app:**
1. **Analytics:** Firebase Console > Analytics > Events
   - Tìm events: `app_opened`, `screen_view`
2. **Crashlytics:** Firebase Console > Crashlytics
   - Sẽ hiển thị sau khi có crash hoặc error

---

## Bước 8: Testing Data với Firestore

### 8.1. Thêm test data trên web
```
Firebase Console > Firestore Database
→ Start collection: "users"
→ Document ID: "test1"
→ Fields: name (string), email (string)
```

### 8.2. Code đọc data
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('users').snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    return ListView(
      children: snapshot.data!.docs.map((doc) {
        return ListTile(
          title: Text(doc['name']),
          subtitle: Text(doc['email']),
        );
      }).toList(),
    );
  },
)
```

---

## Troubleshooting

### Lỗi thường gặp

**1. Firebase Core version conflicts:**
```bash
flutter pub deps
flutter pub upgrade
```

**2. iOS build errors:**
- Kiểm tra iOS deployment target >= 13.0
- Clean project và rebuild

**3. Flutterfire command not found:**
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
source ~/.zshrc  # hoặc ~/.bash_profile
```

**4. Android multidex errors:**
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}
```

### Debug commands
```bash
flutter doctor                    # Kiểm tra setup
flutter logs                      # Xem logs realtime
firebase projects:list            # List Firebase projects
flutterfire configure --help      # Xem options
```

---

## Kết quả cuối cùng

Sau khi hoàn thành, bạn sẽ có:

✅ **Firebase Project** kết nối với Flutter app  
✅ **Analytics tracking** tự động (screen views, custom events)  
✅ **Crash reporting** tự động gửi về Firebase  
✅ **Firestore Database** để lưu trữ data  
✅ **Cross-platform support** (Android, iOS, Web)  

### Files được tạo:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### Dependencies trong pubspec.yaml:
```yaml
dependencies:
  firebase_core: ^2.15.1
  firebase_analytics: ^latest
  firebase_crashlytics: ^latest
  cloud_firestore: ^latest  # nếu cần database
```

---

## Lưu ý quan trọng

1. **Backup config files** - google-services.json và GoogleService-Info.plist
2. **Test trên real devices** - Analytics cần thời gian để hiển thị data
3. **Production build** - Đảm bảo test release build trước khi publish
4. **Security rules** - Cập nhật Firestore rules khi deploy production

---

## Sơ đồ tổng quan setup Firebase

```
📱 Flutter App Setup Firebase
│
├── 🔧 BƯỚC 1: Prerequisites
│   ├── ✅ Node.js + npm
│   ├── ✅ Firebase CLI
│   └── ✅ FlutterFire CLI
│
├── 🏗️ BƯỚC 2: Firebase Project
│   ├── 🔑 firebase login
│   └── 🆕 Tạo project (CLI hoặc Web Console)
│
├── 🔗 BƯỚC 3: Kết nối App
│   ├── 📋 flutterfire configure
│   │   ├── → lib/firebase_options.dart
│   │   ├── → android/app/google-services.json  
│   │   └── → ios/Runner/GoogleService-Info.plist
│   └── 📦 flutter pub add firebase_core
│
├── 🛠️ BƯỚC 4: Thêm Services
│   ├── 📊 firebase_analytics (tracking users)
│   ├── 💥 firebase_crashlytics (crash reports)
│   └── 🗄️ cloud_firestore (database - optional)
│
├── 💻 BƯỚC 5: Update Code
│   ├── 🚀 Khởi tạo Firebase trong main()
│   ├── 🔍 Setup Crashlytics handler
│   ├── 📈 Log analytics events
│   └── 📱 Thêm screen tracking (GetX)
│
├── 📱 BƯỚC 6: Fix iOS Issues
│   ├── 🎯 iOS deployment target ≥ 13.0
│   └── 🧹 Clean & rebuild
│
├── ✅ BƯỚC 7: Testing
│   ├── 🏃 flutter run
│   ├── 🌐 Test trên web (optional)
│   └── 👀 Kiểm tra Firebase Console
│
└── 🎯 KẾT QUẢ:
    ├── 📊 Analytics tracking tự động
    ├── 💥 Crash reporting tự động  
    ├── 🗄️ Database ready (nếu setup)
    └── 🚀 Production ready!
```

### Workflow thực tế:
```
Setup Tools → Create Project → Connect App → Add Services → Update Code → Fix Issues → Test → Deploy
     ↓              ↓              ↓             ↓            ↓           ↓        ↓       ↓
  5-10 phút     2-3 phút      3-5 phút     2-3 phút    5-10 phút   5-15 phút  2-3 phút  ∞
```

**Tổng thời gian: ~30-45 phút** (tùy thuộc vào iOS issues)

**Firebase setup hoàn tất! 🎉**