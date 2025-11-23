-- ================================================
-- FIX: Add FCM Token Column and Enable Updates
-- ================================================

-- Step 1: Add fcm_token column if not exists
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Step 2: Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_fcm_token 
ON users(fcm_token) 
WHERE fcm_token IS NOT NULL;

-- Step 3: Ensure users can update their own FCM tokens
-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Users can update own FCM token" ON users;

-- Create policy to allow users to update their own FCM token
CREATE POLICY "Users can update own FCM token"
ON users
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Step 4: Add comment for documentation
COMMENT ON COLUMN users.fcm_token IS 'Firebase Cloud Messaging token for push notifications. Updated on each login.';

-- ================================================
-- Verification Queries
-- ================================================

-- Check if column was created successfully
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
  AND column_name = 'fcm_token';

-- Check current FCM token status for all users
SELECT 
    COUNT(*) as total_users,
    COUNT(fcm_token) as users_with_tokens,
    COUNT(*) - COUNT(fcm_token) as users_need_login,
    ROUND(
        (COUNT(fcm_token)::numeric / NULLIF(COUNT(*), 0)::numeric * 100), 
        2
    ) as token_coverage_percent
FROM users;

-- ================================================
-- Next Steps (Run manually after this migration)
-- ================================================

-- After running this migration:
-- 1. All users must LOG OUT
-- 2. All users must LOG IN again
-- 3. Run this query to verify tokens are saved:
--
-- SELECT user_id, email, 
--        CASE 
--          WHEN fcm_token IS NULL THEN '❌ Need Login'
--          ELSE '✅ Has Token'
--        END as status
-- FROM users
-- ORDER BY updated_at DESC;

