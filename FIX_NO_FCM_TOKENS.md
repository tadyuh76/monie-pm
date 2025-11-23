# Fix: No FCM Tokens Found

## Vấn đề

Khi thêm expense, logs hiển thị:

```
📤 [GroupRemoteDataSource] Sending push notifications to 1 member(s)
! [GroupRemoteDataSource] No FCM tokens found for members
```

**Nguyên nhân:** FCM tokens chưa được lưu vào database.

## Giải pháp - 3 Bước

### Bước 1: Đảm bảo column `fcm_token` tồn tại

Chạy SQL này trong **Supabase Dashboard → SQL Editor**:

```sql
-- Add column nếu chưa có
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Tạo index
CREATE INDEX IF NOT EXISTS idx_users_fcm_token 
ON users(fcm_token) 
WHERE fcm_token IS NOT NULL;

-- Verify column đã tồn tại
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
  AND column_name = 'fcm_token';
```

**Expected result:**
```
column_name | data_type
------------|----------
fcm_token   | text
```

### Bước 2: Log out và Log in lại TẤT CẢ users

**Quan trọng:** Mọi user trong group phải **log out hoàn toàn** rồi **log in lại**.

**Trên mỗi device:**
1. Mở app
2. Vào Settings/Account
3. **Log Out**
4. **Đóng app hoàn toàn** (force close)
5. Mở lại app
6. **Log In** với tài khoản

**Tại sao?** Khi login, app sẽ:
- Lấy FCM token từ Firebase
- Lưu vào database qua `_updateFcmToken()`

### Bước 3: Verify tokens đã được lưu

Chạy SQL này để check:

```sql
-- Xem tất cả FCM tokens
SELECT 
    user_id, 
    email, 
    CASE 
        WHEN fcm_token IS NULL THEN '❌ NULL'
        WHEN fcm_token = '' THEN '❌ Empty'
        ELSE '✅ Has Token'
    END as token_status,
    LEFT(fcm_token, 20) || '...' as token_preview,
    updated_at
FROM users
ORDER BY updated_at DESC;
```

**Expected result:**
```
email                | token_status | token_preview           | updated_at
---------------------|--------------|-------------------------|-------------------
user1@example.com    | ✅ Has Token | eR5Y6h7j8k9l0m1n2o... | 2025-11-23 15:30:00
user2@example.com    | ✅ Has Token | fS6Z7i8k9l0m1n2o3p... | 2025-11-23 15:29:00
```

**Nếu vẫn thấy "❌ NULL":**
- User chưa login lại
- Hoặc có lỗi khi save token

## Debug: Check logs khi Login

Khi user **login**, check console logs:

**Expected logs khi login thành công:**

```
I/flutter: ✅ User authenticated
I/flutter: 🔔 Updating FCM token...
I/flutter: ✅ FCM token saved: eR5Y6h7j8k9l0m1n2o3p...
```

**Nếu KHÔNG thấy logs trên:**

### Fix A: Thêm logs vào auth_wrapper.dart

Mở file `lib/features/authentication/presentation/pages/auth_wrapper.dart` và tìm method `_updateFcmToken`:

```dart
void _updateFcmToken(BuildContext context) async {
  try {
    print('🔔 [AuthWrapper] Updating FCM token...'); // ← Thêm log này
    
    final notificationService = sl<NotificationService>();
    final token = await notificationService.getToken();
    
    print('🔔 [AuthWrapper] FCM token: ${token?.substring(0, 20)}...'); // ← Thêm log này
    
    if (token != null && context.mounted) {
      // Update FCM token in the database
      context.read<AuthBloc>().add(UpdateFcmTokenEvent(token: token));
      print('✅ [AuthWrapper] FCM token update event sent'); // ← Thêm log này
    } else {
      print('⚠️ [AuthWrapper] FCM token is null or context unmounted'); // ← Thêm log này
    }
  } catch (e) {
    print('❌ [AuthWrapper] Failed to update FCM token: $e'); // ← Thêm log này
  }
}
```

Sau đó rebuild app:
```bash
flutter run
```

### Fix B: Check NotificationService initialization

Mở file `lib/core/services/notification_service.dart` và tìm method `getToken`:

```dart
Future<String?> getToken() async {
  try {
    print('🔔 [NotificationService] Getting FCM token...');
    final token = await _firebaseMessaging.getToken();
    print('🔔 [NotificationService] Got token: ${token?.substring(0, 20)}...');
    return token;
  } catch (e) {
    print('❌ [NotificationService] Failed to get token: $e');
    return null;
  }
}
```

### Fix C: Check notification permission

FCM token chỉ được cấp khi app có notification permission.

**Android:**
1. Settings → Apps → Monie → Notifications
2. Đảm bảo **BẬT**

**Nếu bị TẮT:**
1. BẬT lại
2. Log out
3. Log in lại

## Test lại

Sau khi login lại:

1. **Check database:**
   ```sql
   SELECT user_id, email, fcm_token FROM users;
   ```
   → Phải thấy tokens

2. **Add expense:**
   - Device A: Thêm expense
   - Check logs

**Expected logs:**
```
📤 [GroupRemoteDataSource] Sending push notifications to 1 member(s)
📤 [GroupRemoteDataSource] Found 1 FCM token(s)  ← Khác!
✅ [GroupRemoteDataSource] Push notifications sent successfully
```

3. **Device B nhận notification:**
   - ✅ Push notification banner
   - ✅ In-app notification

## Troubleshooting

### Issue: Token vẫn NULL sau khi login

**Nguyên nhân:** AuthBloc không xử lý UpdateFcmTokenEvent.

**Solution:** Check file `lib/features/authentication/presentation/bloc/auth_bloc.dart`:

```dart
// Phải có handler cho UpdateFcmTokenEvent
on<UpdateFcmTokenEvent>((event, emit) async {
  final result = await _updateFcmToken(UpdateFcmTokenParams(token: event.token));
  // ... xử lý result
});
```

### Issue: "Permission denied" khi lưu token

**Nguyên nhân:** Supabase RLS policies.

**Solution:** Check policies cho table `users`:

```sql
-- Allow users to update their own FCM token
CREATE POLICY "Users can update own FCM token"
ON users
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);
```

### Issue: Firebase not initialized

**Logs:**
```
❌ [NotificationService] Failed to get token: [core/no-app]
```

**Solution:** Đảm bảo Firebase được initialize trong `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(); // ← Phải có dòng này
  
  // ... rest of initialization
}
```

## Quick Test Script

Chạy script SQL này để check status của tất cả users:

```sql
-- Check FCM token status for all users
WITH token_check AS (
  SELECT 
    user_id,
    email,
    fcm_token,
    CASE 
      WHEN fcm_token IS NULL THEN '❌ Need Login'
      WHEN fcm_token = '' THEN '❌ Need Login'
      WHEN LENGTH(fcm_token) < 50 THEN '⚠️ Invalid Token'
      ELSE '✅ Ready'
    END as status,
    updated_at
  FROM users
)
SELECT 
  status,
  COUNT(*) as user_count,
  ARRAY_AGG(email) as emails
FROM token_check
GROUP BY status
ORDER BY 
  CASE status
    WHEN '✅ Ready' THEN 1
    WHEN '⚠️ Invalid Token' THEN 2
    ELSE 3
  END;
```

**Expected result khi OK:**
```
status      | user_count | emails
------------|------------|---------------------------
✅ Ready    | 2          | {user1@example.com, user2@example.com}
```

## Summary

1. ✅ Add column `fcm_token` nếu chưa có
2. ✅ **Log out và login lại TẤT CẢ users**
3. ✅ Verify tokens trong database
4. ✅ Test push notification lại

---

**Quick Fix Checklist:**
- [ ] Run SQL to add column
- [ ] Log out ALL users
- [ ] Log in ALL users  
- [ ] Check SQL query shows tokens
- [ ] Test add expense
- [ ] Verify logs show "Found X FCM token(s)"
- [ ] Confirm notification received

**Time:** 5 minutes  
**Most Important:** Step 2 - LOG OUT AND LOG IN AGAIN!

