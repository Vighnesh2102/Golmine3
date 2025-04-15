-- This is the minimum necessary fix for the profile insertion issue

-- Drop any existing insert policies on the profiles table
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Anyone can insert profiles" ON profiles;

-- Create a new policy that allows anyone to insert into profiles
-- This ensures profiles can be created during the signup flow
CREATE POLICY "Anyone can insert profiles" 
  ON profiles FOR INSERT 
  WITH CHECK (true);

-- Make sure RLS is enabled (this is likely already the case)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY; 