# BTL khai phá dữ liệu và máy học trong an toàn hệ thống

## Tổng Quan Dự Án

Dự án này là một phần của nghiên cứu về khai phá dữ liệu và học máy trong an toàn hệ thống. Ứng dụng bao gồm:

- Ứng dụng di động phía client cho người dùng
- Máy chủ backend với giao tiếp thời gian thực
- Các thành phần học máy để tăng cường bảo mật

## Tính Năng

- Nhắn tin thời gian thực
- Xác thực người dùng (Đăng nhập/Đăng ký)
- Giao tiếp an toàn
- Giao diện người dùng Material Design hiện đại
- Lưu trữ trạng thái đăng nhập

## Công Nghệ Sử Dụng

- Frontend: Flutter
- Quản lý trạng thái: Provider
- Lưu trữ cục bộ: SharedPreferences
- Giao tiếp thời gian thực: WebSocket
- Backend: https://github.com/ducvnkm2k4/chat-app-backend.git
- Học Máy: https://github.com/ducvnkm2k4/btl_dmml_net.git
- báo cáo nghiên cứu: https://docs.google.com/document/d/1omlw5fgTNDKg2MKwOU_6PcMlskKjncK8jpQO8l9orgg/edit?tab=t.0

## Cấu Trúc Dự Án

```
chat_app/
├── lib/
│   ├── main.dart                 # Khởi tạo ứng dụng và cấu hình routes
│   ├── screens/                  # Các màn hình chính
│   │   ├── login_screen.dart     # Màn hình đăng nhập
│   │   ├── sign_up_screen.dart   # Màn hình đăng ký
│   │   └── chat_detail_screen.dart # Màn hình chat
│   ├── service/                  # Các service
│   │   ├── auth_services.dart    # Xử lý xác thực
│   │   ├── message_services.dart # Xử lý tin nhắn
│   │   ├── message_provider.dart # Quản lý trạng thái tin nhắn
│   │   └── socket_service.dart   # Xử lý kết nối socket
│   └── models/                   # Các model dữ liệu
│       ├── user.dart            # Model người dùng
│       └── message.dart         # Model tin nhắn
├── android/                      # Cấu hình Android
├── web/                         # Cấu hình Web
├── pubspec.yaml                 # Cấu hình dự án và dependencies
└── README.md                    # Tài liệu dự án
```
