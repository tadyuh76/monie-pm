# Push Notification Troubleshooting Guide

## Current Implementation Status

### ✅ COMPLETE - All Infrastructure Is In Place

The push notification system for group expenses is **fully implemented**:

1. **FCM Token Management** (`lib/features/authentication/presentation/pages/auth_wrapper.dart`)
   - FCM tokens are automatically fetched and saved when users log in
   - Tokens are stored in `users.fcm_token` column

2. **Push Notification Triggers** (`lib/features/groups/data/datasources/group_remote_datasource.dart`)
   - `addGroupExpense()` method calls `_sendPushNotifications()` after creating in-app notifications
   - Handles both auto-approved (notify all members) and pending approval (notify admins) flows

3. **Edge Function Integration** (`lib/features/groups/data/datasources/group_remote_datasource.dart`)
   - `_sendPushNotifications()` method fetches FCM tokens and calls Supabase Edge Function
   - Edge Function `send-group-notification` sends FCM push notifications

4. **Backend** (`supabase/functions/send-group-notification/`)
   - Edge Function uses Firebase Admin SDK to send multicast notifications
   - Configured with FIREBASE_SERVICE_ACCOUNT secret

## Troubleshooting Steps

If push notifications are not working, follow these steps:

### Step 1: Verify FCM Tokens Are Being Saved

```sql
-- Run in Supabase SQL Editor
SELECT user_id, email, fcm_token, updated_at 
FROM users 
WHERE fcm_token IS NOT NULL
ORDER BY updated_at DESC;
```

**Expected:** You should see FCM tokens for users who have logged in recently.

**If tokens are NULL:**
- Check that `NotificationService().initialize()` is called on app startup
- Verify notification permissions are granted on the device
- Check app logs for FCM token retrieval errors

### Step 2: Check App Logs When Adding Expense

When you add a group expense, check logs for these messages:

```
📤 [GroupRemoteDataSource] Sending push notifications to X member(s)
📤 [GroupRemoteDataSource] Found X FCM token(s)
✅ [GroupRemoteDataSource] Push notifications sent successfully
   - Success: X
   - Failed: 0
```

**If you see:**
- `⚠️ No FCM tokens found for members` → FCM tokens aren't saved (see Step 1)
- `❌ Failed to send push notifications` → Edge Function error (see Step 3)

### Step 3: Verify Edge Function Is Deployed

```bash
# Check if function exists
supabase functions list

# Check function logs
supabase functions logs send-group-notification --limit 20
```

**Expected logs when notification is sent:**
```
📩 Received push notification request
📤 Sending notification to X device(s)
📝 Title: New Group Expense
📝 Body: ...
✅ Successfully sent: X
❌ Failed: 0
```

**If function doesn't exist:**
```bash
# Deploy the function
supabase functions deploy send-group-notification
```

**If function fails:**
- Check FIREBASE_SERVICE_ACCOUNT secret is set:
  ```bash
  supabase secrets list
  ```
- Verify the service account JSON is valid
- Check Firebase project ID matches your app

### Step 4: Test Push Notifications

1. **Setup:**
   - Device A: User A (logged in)
   - Device B: User B (logged in)
   - Both users are members of the same group

2. **Test:**
   - On Device A: Add an expense in the group
   - On Device B: Should receive:
     - ✅ In-app notification (in Notifications tab)
     - ✅ Push notification (system notification)

3. **Verify in logs:**
   - Device A logs: Should show "Sending push notifications"
   - Supabase Edge Function logs: Should show notification sent
   - Device B: Should receive notification even if app is closed/background

### Step 5: Check Notification Permissions

**Android:**
- Settings → Apps → Monie → Notifications → Enabled

**Android 13+:**
- App should request `POST_NOTIFICATIONS` permission at runtime
- Check that permission was granted

**iOS:**
- Settings → Monie → Notifications → Allow Notifications

### Step 6: Verify Firebase Configuration

1. Check `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
2. Verify Firebase project ID matches Edge Function configuration
3. Check Firebase Console → Cloud Messaging for any errors

## Common Issues

### Issue: "No FCM tokens found"

**Cause:** Users haven't logged in after FCM integration was added.

**Solution:**
1. Log out all users
2. Log in again
3. Verify tokens are saved with Step 1 query

### Issue: Edge Function Returns 500 Error

**Cause:** FIREBASE_SERVICE_ACCOUNT secret not configured or invalid.

**Solution:**
```bash
# Set the secret (get JSON from Firebase Console → Project Settings → Service Accounts)
supabase secrets set FIREBASE_SERVICE_ACCOUNT='{"type":"service_account",...}'
```

### Issue: Notifications Work in Foreground But Not Background

**Cause:** FCM configuration issue or missing handlers.

**Solution:**
- Check that `FirebaseMessaging.onBackgroundMessage` is configured
- Verify notification channel is created (`AndroidNotificationChannel`)
- Test with app completely closed (force stop)

### Issue: "Requested entity was not found"

**Cause:** Invalid or expired FCM token.

**Solution:**
- Implement token refresh logic
- Delete old tokens from database
- Re-login users to get fresh tokens

## Manual Testing Checklist

- [ ] **FCM Tokens:** Verify tokens are saved in database
- [ ] **App Logs:** Check for "Sending push notifications" message
- [ ] **Edge Function Logs:** Verify function is called and succeeds
- [ ] **Device A → Device B:** Test notification delivery
- [ ] **App Closed:** Test with Device B app completely closed
- [ ] **App Background:** Test with Device B app in background
- [ ] **App Foreground:** Test with Device B app open
- [ ] **Multiple Members:** Test with 3+ group members
- [ ] **Admin Flow:** Test pending approval notifications to admins
- [ ] **Permissions:** Verify notification permissions are granted

## Code Locations

If you need to modify the implementation:

- **FCM Token Persistence:** `lib/features/authentication/data/datasources/auth_remote_data_source.dart` (line 387)
- **Token Update on Login:** `lib/features/authentication/presentation/pages/auth_wrapper.dart` (line 74)
- **Push Notification Trigger:** `lib/features/groups/data/datasources/group_remote_datasource.dart` (line 688, 731)
- **Push Send Helper:** `lib/features/groups/data/datasources/group_remote_datasource.dart` (line 929)
- **Edge Function:** `supabase/functions/send-group-notification/index.ts`

## Success Criteria

✅ Push notifications are working when:
1. In-app notifications AND push notifications both appear
2. Notifications work with app closed, background, and foreground
3. All group members receive notifications simultaneously
4. Edge Function logs show 100% success rate
5. No errors in app logs

## Next Steps

If all troubleshooting steps pass but notifications still don't work:
1. Enable verbose logging in Edge Function
2. Use Firebase Console → Cloud Messaging → Test to send a test notification
3. Verify device FCM token is valid by testing with curl:

```bash
# Test Edge Function directly
curl -X POST 'https://YOUR_PROJECT.supabase.co/functions/v1/send-group-notification' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "tokens": ["YOUR_FCM_TOKEN"],
    "title": "Test",
    "body": "Test message",
    "data": {"type": "test"}
  }'
```

---

**Last Updated:** 2025-11-23  
**Status:** ✅ Implementation Complete - Ready for Testing

