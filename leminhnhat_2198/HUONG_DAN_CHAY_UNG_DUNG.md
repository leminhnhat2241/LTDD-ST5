# HƯỚNG DẪN CHẠY ỨNG DỤNG

## 🎯 Chức năng ứng dụng

1. ⚡ **Chuyển đổi nhiệt độ** (Celsius, Fahrenheit, Kelvin)
2. 📏 **Chuyển đổi đơn vị đo** (Mét, Feet, Km, Dặm)
3. 📺 **Xem video YouTube** (hỗ trợ cả Android và Web)
4. ⏰ **Đồng hồ báo thức** có âm thanh + Voice control
5. ⏱️ **Đồng hồ bấm giờ** (Stopwatch) + Voice control
6. 🎤 **Điều khiển giọng nói toàn cục** - Tự động chuyển màn hình khi gọi tên chức năng

---

## 🌐 Cách 1: Chạy trên Chrome

### Bước 1: Mở terminal và chạy

```bash
flutter run -d chrome
```

### Bước 2: Đợi ứng dụng khởi động

- Ứng dụng sẽ tự động mở trong trình duyệt Chrome
- Video YouTube hoạt động tốt trên web
- ⚠️ Voice control KHÔNG hoạt động trên web

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
- **YouTube player** hoạt động bình thường (dùng youtube_player_flutter)
- Tất cả chức năng chuyển đổi và đồng hồ hoạt động tốtew
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

- ✅ Voice control toàn cục (chuyển màn hình tự động)
- ✅ Voice control cho báo thức (hẹn báo thức, hủy)
- ✅ Voice control cho bấm giờ (bắt đầu, dừng, vòng, reset)
- ✅ YouTube player phát video trong app
- ✅ Âm thanh báo thức
- ✅ Tất cả chức năng chuyển đổi

## 🎤 Hướng dẫn sử dụng Voice Control

### 🏠 Điều khiển toàn cục (Màn hình chính):

Nhấn icon microphone trên AppBar, sau đó nói:

- 🗣️ **"Nhiệt độ"** → Chuyển đến màn hình chuyển đổi nhiệt độ
- 🗣️ **"Đơn vị"** → Chuyển đến màn hình chuyển đổi đơn vị
- 🗣️ **"YouTube"** hoặc **"Video"** → Chuyển đến màn hình xem video
- 🗣️ **"Báo thức"** → Chuyển đến màn hình đồng hồ báo thức
- 🗣️ **"Bấm giờ"** → Chuyển đến màn hình đồng hồ bấm giờ

### ⏰ Đồng hồ báo thức:

- 🗣️ **"Hẹn báo thức 7 giờ 30"** → Tự động đặt và kích hoạt báo thức
- 🗣️ **"Đặt báo thức 14 giờ 30"** → Tự động đặt và kích hoạt báo thức
- 🗣️ **"Đặt báo thức 7:30"** → Hỗ trợ cả format giờ:phút
- 🗣️ **"Hủy báo thức"** → Hủy báo thức đã đặt

### ⏱️ Đồng hồ bấm giờ:

- 🗣️ **"Bắt đầu"** hoặc "Start" → Khởi động stopwatch
- 🗣️ **"Dừng"** hoặc "Stop" → Tạm dừng

## 📺 Hướng dẫn xem YouTube

### Định dạng link hỗ trợ:

- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://www.youtube.com/embed/VIDEO_ID`
- `https://www.youtube.com/v/VIDEO_ID`

### Cách sử dụng:

1. Copy link video từ YouTube
2. Dán vào ô nhập liệu
3. Nhấn nút **"Phát video"**
4. Video sẽ phát trực tiếp trong ứng dụng (cả Android và Web)
5. Có nút **icon ⤴** trên AppBar để mở trong YouTube app/web

### Tính năng:

- ✅ Thanh progress bar màu đỏ
- ✅ Nút điều khiển: play/pause, tua, tốc độ phát
- ✅ Nút full screen
- ✅ Hiển thị thời gian hiện tại và còn lại

### Lỗi: YouTube không phát

**Giải pháp:**

- Kiểm tra kết nối Internet
- Đảm bảo link YouTube hợp lệ
- Thử link YouTube khác
- Video có thể bị chặn ở một số quốc gia

- Video phát trực tiếp trong ứng dụng

### Trên Mobile:

- Có nút "Mở trong YouTube" để xem trong app YouTube

---

## 🔧 Khắc phục sự cố

## 🚀 Khuyến nghị

| Nền tảng    | YouTube | Voice     | Báo thức | Khuyến nghị              |
| ----------- | ------- | --------- | -------- | ------------------------ |
| **Chrome**  | ✅ Tốt  | ❌ Không  | ✅ OK    | ⭐⭐⭐⭐ Phát triển/Test |
| **Windows** | ✅ Tốt  | ❌ Không  | ✅ OK    | ⭐⭐⭐⭐ Cần Dev Mode    |
| **Android** | ✅ Tốt  | ✅ Đầy đủ | ✅ Tốt   | ⭐⭐⭐⭐⭐ Tốt nhất      |

### 🎯 Lựa chọn tốt nhất:

1. **Trải nghiệm đầy đủ**: Dùng **Android** (có Voice control toàn cục)
2. **Phát triển/Test nhanh**: Dùng **Chrome**
3. **Windows Desktop**: OK nhưng không có Voice

### Lỗi: Voice không hoạt động

**Giải pháp:**

- Chỉ hoạt động trên thiết bị thật (Android/iOS)

## 📦 Packages đã sử dụng

```yaml
dependencies:
  cupertino_icons: ^1.0.8 # Icons Material & Cupertino
  youtube_player_flutter: ^9.0.3 # YouTube player (Android & Web)
  audioplayers: ^6.1.0 # Phát âm thanh báo thức
  intl: ^0.19.0 # Format ngày giờ
  speech_to_text: ^7.0.0 # Nhận diện giọng nói
  permission_handler: ^11.3.1 # Quản lý quyền (microphone)
  url_launcher: ^6.3.1 # Mở link YouTube external
```

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
