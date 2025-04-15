-- This script only updates RLS policies for the existing profiles table
-- without dropping or recreating the table

-- First, let's update the policies for the profiles table

-- Check if RLS is enabled, and enable it if not
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop the existing insert policy if it exists
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Anyone can insert profiles" ON profiles;

-- Create a new policy that allows anyone to insert into profiles
CREATE POLICY "Anyone can insert profiles" 
  ON profiles FOR INSERT 
  WITH CHECK (true);

-- Ensure the select and update policies exist
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
CREATE POLICY "Users can view their own profile" 
  ON profiles FOR SELECT 
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
CREATE POLICY "Users can update their own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Note: If you'd prefer a more restrictive policy that still allows signup, you can use:
CREATE POLICY "Users can insert their own profile" 
  ON profiles FOR INSERT 
  WITH CHECK (auth.uid() = id OR auth.role() = 'anon'); 