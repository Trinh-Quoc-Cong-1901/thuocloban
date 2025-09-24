# Hướng Dẫn Thêm Icon App Cho Flutter

## Tổng quan

Hướng dẫn này sẽ giúp bạn thêm icon cho ứng dụng Flutter trên cả Android và iOS.

## Yêu cầu

- File icon gốc có kích thước ít nhất 1024x1024 pixels
- Format: PNG hoặc JPG
- Nền trong suốt (khuyến nghị cho Android)

## Phương pháp 1: Sử dụng flutter_launcher_icons (Khuyến nghị)

### Bước 1: Thêm dependency

Mở file `pubspec.yaml` và thêm vào phần `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### Bước 2: Cấu hình icon

Thêm cấu hình sau vào cuối file `pubspec.yaml`:

```yaml
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/icon.png"
  min_sdk_android: 21 # android min sdk min:16, default 21
  web:
    generate: true
    image_path: "assets/icon/icon.png"
    background_color: "#hexcode"
    theme_color: "#hexcode"
  windows:
    generate: true
    image_path: "assets/icon/icon.png"
    icon_size: 48 # min:48, max:256, default: 48
  macos:
    generate: true
    image_path: "assets/icon/icon.png"
```

### Bước 3: Tạo thư mục và thêm icon

1. Tạo thư mục `assets/icon/` trong dự án
2. Đặt file icon của bạn vào thư mục này với tên `icon.png`

### Bước 4: Chạy lệnh tạo icon

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

## Phương pháp 2: Thủ công

### Android

1. Tạo các kích thước icon khác nhau:
   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Vào `Runner > Assets.xcassets > AppIcon.appiconset`
3. Kéo thả các file icon với kích thước tương ứng

## Icon Adaptive cho Android (Android 8.0+)

### Cấu hình adaptive icon

Thêm vào `flutter_icons` trong `pubspec.yaml`:

```yaml
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "assets/icon/background.png"
  adaptive_icon_foreground: "assets/icon/foreground.png"
```

## Lưu ý quan trọng

1. **Kích thước icon**: Sử dụng icon có độ phân giải cao (1024x1024) để đảm bảo chất lượng
2. **Nền trong suốt**: Khuyến nghị sử dụng nền trong suốt cho Android
3. **Kiểm tra trước khi build**: Test icon trên nhiều thiết bị khác nhau
4. **Icon guidelines**:
   - Android: Tuân theo Material Design guidelines
   - iOS: Tuân theo Human Interface Guidelines

## Các lệnh hữu ích

### Tạo lại icon

```bash
flutter pub run flutter_launcher_icons:main
```

### Xóa icon cũ và tạo mới

```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons:main
```

### Build và test

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Troubleshooting

### Lỗi thường gặp:

1. **Icon không hiển thị**: Kiểm tra đường dẫn file trong `pubspec.yaml`
2. **Icon bị vỡ**: Đảm bảo file icon có định dạng và kích thước phù hợp
3. **Build lỗi**: Chạy `flutter clean` và thử lại

### Kiểm tra icon đã được tạo:

- Android: Kiểm tra thư mục `android/app/src/main/res/mipmap-*/`
- iOS: Kiểm tra trong Xcode tại `Assets.xcassets/AppIcon.appiconset/`

## Kết luận

Sau khi hoàn thành các bước trên, icon ứng dụng của bạn sẽ xuất hiện trên màn hình chính của thiết bị. Hãy build và test ứng dụng để đảm bảo icon hiển thị chính xác.

flutter_launcher_icons:
android: true
ios: true
image_path: "assets/icons/logo_app.png"
