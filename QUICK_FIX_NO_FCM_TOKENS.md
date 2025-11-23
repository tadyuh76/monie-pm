# ⚡ Quick Fix: No FCM Tokens

## Vấn đề

```
! [GroupRemoteDataSource] No FCM tokens found for members
```

## Giải pháp 3 Bước (5 phút)

### 1️⃣ Run SQL (1 phút)

**Supabase Dashboard → SQL Editor** → Paste và Run:

```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;
CREATE INDEX IF NOT EXISTS idx_users_fcm_token ON users(fcm_token);
```

### 2️⃣ Log Out + Log In (2 phút)

**TẤT CẢ users trong group phải:**

1. Log Out
2. **Close app hoàn toàn**
3. Open app
4. Log In lại

### 3️⃣ Verify (1 phút)

**Check database:**

```sql
SELECT email, 
       CASE WHEN fcm_token IS NULL THEN '❌ Need Login' ELSE '✅ OK' END 
FROM users;
```

**All users phải là ✅ OK**

### 4️⃣ Test

Add expense → Check logs:

```
📤 Sending push notifications to 1 member(s)
📤 Found 1 FCM token(s)  ← Phải thấy dòng này!
✅ Push notifications sent successfully
```

---

## Nếu vẫn lỗi

**Check logs khi login:**

```
🔔 [AuthWrapper] Updating FCM token...
✅ [AuthWrapper] FCM token saved
```

**Không thấy?** → Check notification permission:
- Settings → Apps → Monie → Notifications → **BẬT**

---

**TL;DR:** Add column SQL + Log out/in ALL users = Fixed! 🎉

See `FIX_NO_FCM_TOKENS.md` for detailed troubleshooting.

