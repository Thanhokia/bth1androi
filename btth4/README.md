# Trạm Khảo sát (Survey Station)

Ứng dụng Flutter để thu thập và hiển thị dữ liệu cảm biến từ các điểm khảo sát.

## Tính năng

### 1. Màn hình "Trạm Khảo sát" (Survey Station)
- **Hiển thị Dữ liệu Trực tiếp:**
  - Cường độ Ánh sáng: Giá trị lux hiện tại (mô phỏng)
  - Độ "Năng động": Độ lớn vector gia tốc từ Gia tốc kế
  - Cường độ Từ trường: Độ lớn vector từ trường từ Từ kế
  - Tọa độ GPS: Vĩ độ và kinh độ hiện tại

- **Nút "Ghi Dữ liệu tại Điểm này":**
  - Lấy tọa độ GPS chính xác
  - Thu thập tất cả giá trị cảm biến hiện tại
  - Lưu dữ liệu với timestamp vào file JSON local

### 2. Màn hình "Bản đồ Dữ liệu" (Data Map)
- **Danh sách Điểm Khảo sát:**
  - Hiển thị tất cả dữ liệu đã thu thập
  - Sắp xếp theo thời gian (mới nhất trước)

- **Trực quan hóa Dữ liệu:**
  - Ánh sáng: Icon mặt trời ☀️ với màu vàng (cường độ cao = vàng đậm)
  - Năng động: Icon bước chân 🚶 với màu đỏ (gia tốc cao = đỏ đậm)
  - Từ trường: Icon nam châm 🧲 với màu xanh dương (cường độ cao = xanh đậm)

## Cài đặt và Chạy

1. Cài đặt dependencies:
```bash
flutter pub get
```

2. Chạy ứng dụng:
```bash
flutter run
```

## Quyền cần thiết

- **Location Permission**: Để lấy tọa độ GPS
- **Sensors**: Để đọc dữ liệu từ gia tốc kế và từ kế

## Cấu trúc Dự án

```
lib/
├── main.dart                    # Entry point và navigation
├── models/
│   └── survey_data.dart        # Data model cho dữ liệu khảo sát
└── screens/
    ├── survey_station_screen.dart  # Màn hình thu thập dữ liệu
    └── data_map_screen.dart        # Màn hình hiển thị dữ liệu
```

## Lưu trữ Dữ liệu

Dữ liệu được lưu trong file `schoolyard_map_data.json` trong thư mục documents của ứng dụng.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
