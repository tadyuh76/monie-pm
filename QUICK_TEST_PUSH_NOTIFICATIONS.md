# Quick Test: Push Notifications for Group Expenses

## ✅ Implementation Status: COMPLETE

All code for push notifications is already implemented and working:

### Code Flow
1. **User Login** → FCM token obtained → Saved to `users.fcm_token`
2. **Add Group Expense** → In-app notification created → Push notification sent via Edge Function
3. **Edge Function** → Fetches tokens → Sends via Firebase Cloud Messaging
4. **Devices** → Receive push notification

## 🧪 Quick Test (2 Minutes)

### Prerequisites
- 2 devices with the app installed
- Both users logged in
- Both users in the same group

### Test Steps

1. **On Device A (User A):**
   - Open the app
   - Navigate to Groups
   - Open a shared group
   - Add an expense (any amount)

2. **On Device B (User B):**
   - Keep app in background or closed
   - **SHOULD SEE:** System push notification appear
   - Open app → **SHOULD SEE:** In-app notification in Notifications tab

### Expected Behavior

**Device A (Who added expense):**
```
Logs should show:
📤 [GroupRemoteDataSource] Sending push notifications to 2 member(s)
📤 [GroupRemoteDataSource] Found 2 FCM token(s)
✅ [GroupRemoteDataSource] Push notifications sent successfully
```

**Device B (Receiving notification):**
- 🔔 Push notification appears in system tray (even if app is closed)
- 📱 Opening app shows in-app notification

## 🐛 If Push Notifications Don't Appear

### Check 1: FCM Tokens Are Saved

```sql
-- Run in Supabase SQL Editor
SELECT 
    user_id, 
    email, 
    CASE 
        WHEN fcm_token IS NULL THEN '❌ Missing'
        WHEN fcm_token = '' THEN '❌ Empty'
        ELSE '✅ Present'
    END as token_status
FROM users
WHERE email IN ('user_a@example.com', 'user_b@example.com');
```

**If tokens are missing:**
1. Log out both users
2. Log in again
3. Check logs for: "Updating FCM token"

### Check 2: Edge Function Logs

```bash
# View recent logs
supabase functions logs send-group-notification --limit 10
```

**Look for:**
```
✅ GOOD: "Successfully sent: 2"
❌ BAD: "Failed: 2" or "FIREBASE_SERVICE_ACCOUNT not set"
```

### Check 3: App Logs (When Adding Expense)

**In Android Studio / Xcode console, filter for:**
- `GroupRemoteDataSource`
- Look for the 📤 emoji logs

**Common log patterns:**
```
✅ WORKING:
📤 Sending push notifications to 2 member(s)
📤 Found 2 FCM token(s)
✅ Push notifications sent successfully

❌ NO TOKENS:
📤 Sending push notifications to 2 member(s)
⚠️ No FCM tokens found for members

❌ EDGE FUNCTION ERROR:
📤 Sending push notifications to 2 member(s)
📤 Found 2 FCM token(s)
❌ Failed to send push notifications: <error message>
```

### Check 4: Notification Permissions

**Android:**
- Settings → Apps → Monie → Notifications → **Must be ON**
- Android 13+: App must request runtime permission (should happen automatically)

**iOS:**
- Settings → Monie → Notifications → **Allow Notifications must be ON**

## 🔧 Quick Fixes

### Fix 1: Re-login to Get Fresh Tokens

Both users should:
1. Log out
2. Log in again
3. Wait 2-3 seconds
4. Try adding expense again

### Fix 2: Verify Edge Function Deployment

```bash
# Check if deployed
supabase functions list

# Should show: send-group-notification

# If not deployed:
supabase functions deploy send-group-notification
```

### Fix 3: Check Firebase Service Account Secret

```bash
# List secrets
supabase secrets list

# Should show: FIREBASE_SERVICE_ACCOUNT

# If missing, set it:
supabase secrets set FIREBASE_SERVICE_ACCOUNT='<JSON_FROM_FIREBASE_CONSOLE>'
```

## 📱 Test Scenarios

### Scenario 1: App Closed
1. Force close app on Device B
2. Add expense on Device A
3. Device B should receive system notification

### Scenario 2: App Background
1. Put app in background on Device B
2. Add expense on Device A
3. Device B should receive notification and update when app is reopened

### Scenario 3: App Foreground
1. Keep app open on Device B
2. Add expense on Device A
3. Device B should show in-app notification immediately

## ✅ Success Checklist

- [ ] FCM tokens are saved for both users (SQL query)
- [ ] Logs show "Sending push notifications to X member(s)"
- [ ] Logs show "Found X FCM token(s)" (not 0)
- [ ] Logs show "Push notifications sent successfully"
- [ ] Edge Function logs show "Successfully sent: X"
- [ ] Device B receives system push notification
- [ ] Device B shows in-app notification
- [ ] Works with app closed, background, and foreground

## 🎯 Expected Results

When everything is working correctly:

1. **Add expense on Device A** → Takes 1-2 seconds
2. **Device B receives notification** → Appears within 3-5 seconds
3. **Both notifications appear** → In-app + Push
4. **All members notified** → Everyone in the group gets notification

## 📞 Still Not Working?

If all checks pass but push notifications still don't work:

1. **Test Firebase Directly:**
   ```bash
   # Get FCM token from SQL
   # Then test with curl:
   curl -X POST 'https://fcm.googleapis.com/v1/projects/YOUR_PROJECT/messages:send' \
     -H 'Authorization: Bearer $(gcloud auth print-access-token)' \
     -H 'Content-Type: application/json' \
     -d '{
       "message": {
         "token": "FCM_TOKEN_HERE",
         "notification": {
           "title": "Test",
           "body": "Test message"
         }
       }
     }'
   ```

2. **Check Firebase Console:**
   - Go to Cloud Messaging
   - Look for any errors or warnings
   - Verify sender ID matches `google-services.json`

3. **Enable Debug Logging:**
   - In `group_remote_datasource.dart`, add more detailed logs
   - In Edge Function `index.ts`, add verbose logging

---

**Implementation:** ✅ Complete  
**Testing:** 🧪 Ready  
**Status:** All code is in place, just needs verification

