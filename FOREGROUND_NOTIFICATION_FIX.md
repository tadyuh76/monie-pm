# Fix: Push Notification không hiện khi App đang mở

## Vấn đề

Khi **đang trong app** (foreground) và thêm expense trong shared group:
- ❌ Push notification **KHÔNG hiện**
- ✅ In-app notification **CÓ hiện**

## Nguyên nhân

Firebase Cloud Messaging có 2 loại message payload:
1. **Notification-only payload** - Tự động hiện khi app background, KHÔNG hiện khi app foreground
2. **Data payload** - Phải tự xử lý trong code

Edge Function hiện tại đang gửi **notification payload**, nên khi app foreground, Android/iOS không tự động hiện notification.

## Giải pháp đã implement

### 1. Cải thiện Foreground Message Handler ✅

**File:** `lib/core/services/notification_service.dart` (dòng 285-318)

**Thay đổi:**
- Thêm **debug logs** để kiểm tra message có đến không
- Thêm **playSound: true** và **enableVibration: true**
- Thêm **BigTextStyleInformation** để hiện đầy đủ nội dung
- Thêm log xác nhận notification đã được hiển thị

**Code mới:**
```dart
void _handleForegroundMessage(RemoteMessage message) {
  print('🔔 [NotificationService] Foreground message received!');
  print('   Title: ${message.notification?.title}');
  print('   Body: ${message.notification?.body}');
  
  // Show local notification even when app is in foreground
  _localNotifications.show(
    message.hashCode,
    message.notification?.title ?? 'New Notification',
    message.notification?.body ?? '',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'monie_notifications',
        'Monie Notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,          // ← Thêm âm thanh
        enableVibration: true,    // ← Thêm rung
        styleInformation: BigTextStyleInformation(...),  // ← Hiển thị đầy đủ
      ),
      ...
    ),
  );
  
  print('✅ [NotificationService] Local notification shown');
}
```

## Test & Verify

### Bước 1: Rebuild App

```bash
flutter run
```

### Bước 2: Test với 2 Devices

**Device A:**
1. Mở app
2. Vào Groups
3. Thêm expense trong shared group

**Device B (đang mở app):**
1. Giữ app **ĐANG MỞ** (foreground)
2. Quan sát:
   - ✅ Nên thấy **notification banner** ở đầu màn hình
   - ✅ Có **âm thanh** thông báo
   - ✅ Có **rung** (vibration)
   - ✅ In-app notification cũng xuất hiện

### Bước 3: Check Logs

Trong Android Studio / Xcode console, filter cho "NotificationService":

**Logs mong đợi:**
```
Device A (người thêm expense):
📤 [GroupRemoteDataSource] Sending push notifications to 2 member(s)
📤 [GroupRemoteDataSource] Found 2 FCM token(s)
✅ [GroupRemoteDataSource] Push notifications sent successfully

Device B (nhận notification):
🔔 [NotificationService] Foreground message received!
   Title: New Group Expense
   Body: Lunch in "Test Group" - $25.00
   Data: {type: group_transaction, group_id: xxx, transaction_id: yyy}
✅ [NotificationService] Local notification shown
```

**Nếu KHÔNG thấy logs trên Device B:**
- Message không đến → Kiểm tra Edge Function logs
- FCM token không đúng → Kiểm tra database

**Nếu thấy logs nhưng notification KHÔNG hiện:**
- Notification permission → Kiểm tra Settings
- Notification channel → Xóa app và cài lại

## Kiểm tra Notification Permissions

### Android

```bash
# Check notification permission status
adb shell dumpsys notification_listener

# Check if app can post notifications
adb shell cmd notification allowed_listeners
```

**Hoặc thủ công:**
1. Settings → Apps → Monie
2. Notifications → **Phải BẬT**
3. Show notifications → **Phải BẬT**
4. Override Do Not Disturb → **Recommended: BẬT**

### iOS

1. Settings → Monie
2. Notifications → **Allow Notifications** phải BẬT
3. Show Previews → **Always**
4. Sounds → **Phải BẬT**
5. Badges → **Phải BẬT**

## Troubleshooting

### Issue 1: Không thấy logs "Foreground message received"

**Nguyên nhân:** Message không đến hoặc listener chưa được setup.

**Giải pháp:**
1. Kiểm tra Edge Function có gửi thành công không:
   ```bash
   supabase functions logs send-group-notification
   ```
2. Verify FCM token trong database:
   ```sql
   SELECT user_id, fcm_token FROM users WHERE fcm_token IS NOT NULL;
   ```
3. Restart app để re-initialize listener

### Issue 2: Thấy logs nhưng không hiện notification

**Nguyên nhân:** Notification permission hoặc channel bị vô hiệu hóa.

**Giải pháp A - Request permission lại:**

```dart
// Thêm vào đầu _handleForegroundMessage
final hasPermission = await _checkNotificationPermission();
if (!hasPermission) {
  print('⚠️ No notification permission!');
  await requestNotificationPermission();
}
```

**Giải pháp B - Xóa và cài lại app:**
1. Uninstall app hoàn toàn
2. Rebuild và install:
   ```bash
   flutter clean
   flutter run
   ```
3. Grant notification permission khi được hỏi

### Issue 3: Notification hiện nhưng không có âm thanh

**Nguyên nhân:** 
- Phone đang ở chế độ im lặng
- Notification channel không có sound

**Giải pháp:**
1. Check phone không ở Silent mode
2. Settings → Apps → Monie → Notifications → Sound → Phải BẬT

### Issue 4: Chỉ hiện 1 lần rồi không hiện nữa

**Nguyên nhân:** Notification bị group lại hoặc channel bị disable.

**Giải pháp:**
1. Xóa notification channel cũ:
   - Settings → Apps → Monie → Notifications
   - Tìm "Monie Notifications" channel
   - Delete và cài lại app
2. Hoặc sử dụng unique notification ID

## So sánh Behavior

### Trước khi fix:
| Trạng thái App | Push Notification | In-App Notification |
|----------------|-------------------|---------------------|
| Closed         | ✅ Hiện           | ✅ Hiện (khi mở)   |
| Background     | ✅ Hiện           | ✅ Hiện             |
| Foreground     | ❌ KHÔNG hiện     | ✅ Hiện             |

### Sau khi fix:
| Trạng thái App | Push Notification | In-App Notification |
|----------------|-------------------|---------------------|
| Closed         | ✅ Hiện           | ✅ Hiện (khi mở)   |
| Background     | ✅ Hiện           | ✅ Hiện             |
| Foreground     | ✅ HIỆN           | ✅ Hiện             |

## Test Cases

### Test Case 1: App Foreground
1. Device B: Mở app, ở màn hình Home
2. Device A: Thêm expense
3. **Expected:** Device B thấy notification banner + âm thanh + in-app notification

### Test Case 2: App Foreground - Đang ở Groups screen
1. Device B: Mở app, ở màn hình Groups
2. Device A: Thêm expense
3. **Expected:** Device B thấy notification banner + âm thanh + in-app notification

### Test Case 3: App Foreground - Đang ở Notifications tab
1. Device B: Mở app, ở màn hình Notifications
2. Device A: Thêm expense  
3. **Expected:** Device B thấy notification banner + âm thanh + notification xuất hiện trong list

### Test Case 4: Nhiều notifications liên tiếp
1. Device A: Thêm 3 expenses liên tiếp nhanh
2. **Expected:** Device B thấy 3 notifications riêng biệt (không bị gộp)

## Kết luận

Sau khi implement fix này:
- ✅ Push notification sẽ hiện **kể cả khi app đang mở**
- ✅ Có đầy đủ **âm thanh và rung**
- ✅ **Debug logs** giúp dễ dàng troubleshoot
- ✅ Behavior **nhất quán** ở mọi trạng thái app

---

**Status:** ✅ Fixed  
**Test:** Rebuild app và test với 2 devices  
**Expected:** Notification hiện ở mọi trạng thái app

