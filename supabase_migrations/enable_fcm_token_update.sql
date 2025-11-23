-- ================================================
-- Quick Fix: Enable FCM Token Updates
-- ================================================
-- Run this in Supabase SQL Editor to allow users 
-- to update their own FCM tokens
-- ================================================

-- Add fcm_token column (if not exists)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_fcm_token 
ON users(fcm_token) 
WHERE fcm_token IS NOT NULL;

-- Enable users to update their own FCM tokens
DROP POLICY IF EXISTS "Users can update own FCM token" ON users;

CREATE POLICY "Users can update own FCM token"
ON users FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ================================================
-- After running this script:
-- 1. LOG OUT from all devices
-- 2. LOG IN again on all devices
-- 3. FCM tokens will be saved automatically
-- ================================================

