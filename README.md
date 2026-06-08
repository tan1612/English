# TNT TOEIC Day 11–18 Flutter iOS App

Đây là app Flutter bọc bộ đề HTML offline vào WebView, có audio Day 11–18.

## Cách chạy trên iPhone

1. Cài Flutter và Xcode trên Mac.
2. Mở Terminal tại thư mục này.
3. Chạy:

```bash
flutter pub get
flutter create --platforms=ios .
flutter run
```

Nếu dùng iPhone thật:
- Mở `ios/Runner.xcworkspace` bằng Xcode.
- Chọn `Signing & Capabilities`.
- Chọn Team Apple ID của bạn.
- Cắm iPhone và bấm Run.

## File chính

- `lib/main.dart`: code app Flutter
- `assets/web/index.html`: bộ đề TOEIC
- `assets/web/audio/`: file nghe MP3
- `pubspec.yaml`: khai báo package và assets

## Lưu ý

App chạy offline. Khi mở lần đầu, app copy HTML + MP3 vào bộ nhớ app để WebView trên iOS phát audio ổn định hơn.
