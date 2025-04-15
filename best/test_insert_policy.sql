-- Simple test to verify if the profiles table allows insertions

-- Make sure the insert policy exists
DROP POLICY IF EXISTS "Anyone can insert profiles" ON profiles;
CREATE POLICY "Anyone can insert profiles" 
  ON profiles FOR INSERT 
  WITH CHECK (true);

-- Enable RLS if not already enabled
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Run a simple test query that should succeed with the new policy
DO $$
DECLARE
  test_id UUID := '00000000-0000-0000-0000-000000000001'; -- Test UUID that shouldn't exist
  rows_affected INTEGER;
BEGIN
  BEGIN
    -- Check if test user already exists (shouldn't, but just in case)
    DELETE FROM profiles WHERE id = test_id;
    
    -- Insert test profile
    INSERT INTO profiles (id, full_name, email, phone_number, created_at, updated_at)
    VALUES (
      test_id, 
      'Test User', 
      'test@example.com', 
      '1234567890',
      NOW(),
      NOW()
    );
    
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    
    -- Show success message
    RAISE NOTICE 'TEST PASSED: Successfully inserted % row(s) into profiles', rows_affected;
    
    -- Clean up test data
    DELETE FROM profiles WHERE id = test_id;
    
  EXCEPTION WHEN OTHERS THEN
    -- Show error message
    RAISE NOTICE 'TEST FAILED: Could not insert into profiles table. Error: %', SQLERRM;
  END;
END $$; 