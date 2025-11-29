# HƯỚNG DẪN CHẠY ỨNG DỤNG

## 🎯 Chức năng ứng dụng

1. ⚡ **Chuyển đổi nhiệt độ** (Celsius, Fahrenheit, Kelvin)
2. 📏 **Chuyển đổi đơn vị đo** (Mét, Feet, Km, Dặm)
3. 📺 **Xem video YouTube**
4. ⏰ **Đồng hồ báo thức** có âm thanh
5. ⏱️ **Đồng hồ bấm giờ** (Stopwatch)
6. 🎤 **Điều khiển giọng nói** (Voice control) cho báo thức và bấm giờ

---

## 🌐 Cách 1: Chạy trên Chrome (ĐỀ XUẤT)

### Bước 1: Mở terminal và chạy

```bash
flutter run -d chrome
```

### Bước 2: Đợi ứng dụng khởi động

- Ứng dụng sẽ tự động mở trong trình duyệt Chrome
- Video YouTube hoạt động tốt trên web

---

## 💻 Cách 2: Chạy trên Windows Desktop

### ⚠️ Yêu cầu: Bật Developer Mode

#### Bước 1: Mở Settings

```bash
start ms-settings:developers
```

Hoặc thủ công:

1. Mở **Settings** (Windows + I)
2. Vào **Privacy & Security** → **For developers**
3. Bật **Developer Mode**

#### Bước 2: Chạy ứng dụng

```bash
flutter run -d windows
```

### ⚠️ Lưu ý về Windows:

- **Voice control** KHÔNG hoạt động trên Windows desktop
- YouTube player có thể gặp vấn đề WebView
- Đề xuất sử dụng Chrome thay vì Windows

---

## 📱 Cách 3: Chạy trên Android (ĐẦY ĐỦ TÍNH NĂNG)

### Yêu cầu:

- Điện thoại Android kết nối qua USB hoặc WiFi
- Bật **USB Debugging** trên điện thoại

### Bước 1: Kiểm tra thiết bị

```bash
flutter devices
```

### Bước 2: Chạy trên Android

```bash
flutter run -d <device_id>
```

### ✅ Trên Android, TẤT CẢ tính năng hoạt động:

- ✅ Voice control (báo thức & bấm giờ)
- ✅ YouTube player
- ✅ Âm thanh báo thức
- ✅ Tất cả chuyển đổi

---

## 🎤 Hướng dẫn sử dụng Voice Control

### Đồng hồ báo thức:

- 🗣️ **"Đặt báo thức 7 giờ"**
- 🗣️ **"Đặt báo thức 14 giờ 30"**
- 🗣️ **"Hủy báo thức"**

### Đồng hồ bấm giờ:

- 🗣️ **"Bắt đầu"** hoặc "Start"
- 🗣️ **"Dừng"** hoặc "Stop"
- 🗣️ **"Vòng"** (ghi lại vòng)
- 🗣️ **"Đặt lại"** hoặc "Reset"

### ⚠️ Lưu ý Voice:

- Chỉ hoạt động trên **Android/iOS**
- Cần quyền **Microphone**
- Cần **Internet** để nhận dạng giọng nói

---

## 📺 Hướng dẫn xem YouTube

### Định dạng link hỗ trợ:

- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://www.youtube.com/embed/VIDEO_ID`

### Trên Web (Chrome):

- Video phát trực tiếp trong ứng dụng

### Trên Mobile:

- Có nút "Mở trong YouTube" để xem trong app YouTube

---

## 🔧 Khắc phục sự cố

### Lỗi: "Building with plugins requires symlink support"

**Giải pháp:** Bật Developer Mode hoặc chạy trên Chrome

### Lỗi: YouTube không phát

**Giải pháp:**

- Kiểm tra kết nối Internet
- Chạy trên Chrome thay vì Windows
- Thử link YouTube khác

### Lỗi: Voice không hoạt động

**Giải pháp:**

- Chỉ hoạt động trên thiết bị thật (Android/iOS)
- Không hỗ trợ trên Windows/Web
- Cấp quyền Microphone

---

## 🚀 Khuyến nghị

| Nền tảng    | YouTube | Voice    | Báo thức | Khuyến nghị         |
| ----------- | ------- | -------- | -------- | ------------------- |
| **Chrome**  | ✅ Tốt  | ❌ Không | ✅ OK    | ⭐⭐⭐⭐⭐ Tốt nhất |
| **Windows** | ⚠️ Khó  | ❌ Không | ✅ OK    | ⭐⭐⭐ Cần Dev Mode |
| **Android** | ✅ Tốt  | ✅ Tốt   | ✅ Tốt   | ⭐⭐⭐⭐⭐ Đầy đủ   |

### 🎯 Lựa chọn tốt nhất:

1. **Phát triển/Test**: Dùng **Chrome**
2. **Trải nghiệm đầy đủ**: Dùng **Android**
3. **Windows Desktop**: Cần bật Developer Mode

---

## 📦 Packages đã sử dụng

```yaml
dependencies:
  cupertino_icons: ^1.0.8
  youtube_player_flutter: ^9.0.3
  audioplayers: ^6.1.0
  intl: ^0.19.0
  speech_to_text: ^7.0.0
  permission_handler: ^11.3.1
  url_launcher: ^6.3.1
  webview_flutter: ^4.10.0
```

---

## 📞 Hỗ trợ

Nếu gặp vấn đề:

1. Chạy `flutter clean`
2. Chạy `flutter pub get`
3. Thử chạy trên Chrome: `flutter run -d chrome`
