# Notification System Setup Guide

## Overview
This guide will help you set up the notification system for the Monie app, including the database table creation and testing.

## Prerequisites
- Supabase project set up
- Firebase project configured
- App running with authentication working

## Step 1: Create Notifications Table in Supabase

### Option A: Using Supabase Dashboard (Recommended)
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your `monie-pm` project
3. Navigate to **SQL Editor**
4. Click **New query**
5. Copy and paste the contents of `supabase_migrations/create_notifications_table.sql`
6. Click **Run** or press `Ctrl+Enter`
7. Verify the table was created by checking **Table Editor** → You should see `notifications` table

### Option B: Using Supabase CLI
```bash
# If you have Supabase CLI installed
supabase db push supabase_migrations/create_notifications_table.sql
```

## Step 2: Verify Table Creation

Run this query in SQL Editor to verify:
```sql
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'notifications';
```

Expected columns:
- `notification_id` (uuid)
- `user_id` (uuid)
- `amount` (numeric)
- `type` (text)
- `title` (text)
- `message` (text)
- `is_read` (boolean)
- `created_at` (timestamp with time zone)

## Step 3: Test the Notifications

### Test 1: Add Group Expense
1. Open the app
2. Navigate to a group
3. Add a new expense
4. ✅ **Expected**: No error, expense is added
5. Check Supabase → `notifications` table should have new entries for all group members

### Test 2: View Notifications
1. Tap the notification bell icon on home screen
2. ✅ **Expected**: See list of notifications (or empty state if none)
3. ❌ **Before fix**: "Failed to load notifications: Could not find table"

### Test 3: Daily Reminder (Optional)
1. Wait until 1:00 PM or modify the schedule time in code
2. ✅ **Expected**: See local notification "Don't forget to add your transactions for today!"

## Step 4: Verify Notification Flow

### Query to see all notifications for a user:
```sql
SELECT * FROM notifications 
WHERE user_id = 'YOUR_USER_ID' 
ORDER BY created_at DESC;
```

### Query to see unread notifications:
```sql
SELECT * FROM notifications 
WHERE user_id = 'YOUR_USER_ID' AND is_read = false;
```

## Troubleshooting

### Issue: Still getting "table not found" error
**Solution**: 
1. Verify the table exists in Supabase Dashboard
2. Check if Row Level Security policies are enabled
3. Ensure your user is authenticated when accessing notifications

### Issue: Notifications created but not appearing in app
**Solution**:
1. Check if `user_id` in notifications matches your authenticated user ID
2. Verify RLS policies allow SELECT for authenticated users
3. Check app logs for any errors

### Issue: Group expense created but no notifications
**Solution**:
1. Check if `group_members` table has entries for your group
2. Verify the group transaction code is creating notifications
3. Look for error logs in app console

### Issue: Notification tap doesn't navigate
**Solution**:
1. This is currently logging to console (print statements)
2. To implement actual navigation, you'll need to add a GlobalKey for navigation
3. See TODO comments in `notification_service.dart`

## Error Handling

The app now handles missing table gracefully:
- Returns empty list if table doesn't exist
- Prints warning to console instead of crashing
- Allows other features to work even if notifications aren't set up

## Next Steps

### 1. Set up Push Notifications (FCM)
- Complete Firebase setup (see main guide)
- Test FCM token storage in `users` table
- Send test notification from Firebase Console

### 2. Create Supabase Edge Function
Create an Edge Function to automatically send push notifications when database records are created:

```typescript
// supabase/functions/send-push-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // Triggered when notification is inserted
  const { record } = await req.json()
  
  // Get user's FCM token
  const { data: user } = await supabase
    .from('users')
    .select('fcm_token')
    .eq('user_id', record.user_id)
    .single()
  
  if (user?.fcm_token) {
    // Send FCM push notification
    await sendFCM(user.fcm_token, {
      title: record.title,
      body: record.message,
    })
  }
  
  return new Response('OK')
})
```

### 3. Implement Navigation
Update `notification_service.dart` to use GlobalKey for navigation:
```dart
// In your main.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// In MaterialApp
MaterialApp(
  navigatorKey: navigatorKey,
  // ...
)

// In NotificationService, use:
navigatorKey.currentState?.pushNamed('/group-details', arguments: groupId);
```

## Support
If you encounter any issues, check:
1. Supabase logs in Dashboard
2. Flutter app logs (`flutter logs`)
3. Firebase Console for FCM issues

## Summary

✅ **Completed**:
- Database table structure defined
- Error handling for missing table
- Notification creation in group expenses
- Notification list display
- Basic tap handling (console logs)

🚧 **Pending**:
- Full navigation implementation
- Firebase push notification backend
- Edge Function for automatic push
- iOS APNs configuration

