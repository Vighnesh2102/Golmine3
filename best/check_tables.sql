-- Diagnostic script to check for issues with tables and RLS policies

-- Check if the profiles table exists and its structure
SELECT 
  table_name, 
  column_name, 
  data_type, 
  is_nullable
FROM 
  information_schema.columns
WHERE 
  table_name = 'profiles'
ORDER BY 
  ordinal_position;

-- Check if RLS is enabled for profiles
SELECT
  tablename,
  CASE WHEN rowsecurity THEN 'RLS Enabled' ELSE 'RLS Disabled' END as rls_status
FROM
  pg_tables
WHERE
  schemaname = 'public'
  AND tablename = 'profiles';

-- List all policies on the profiles table
SELECT
  policynamespace.nspname as policy_schema,
  target_table.relname as table_name,
  policy.polname as policy_name,
  pg_get_expr(policy.polqual, policy.polrelid) as using_expression,
  pg_get_expr(policy.polwithcheck, policy.polrelid) as with_check_expression,
  CASE
    WHEN policy.polpermissive THEN 'PERMISSIVE'
    ELSE 'RESTRICTIVE'
  END as permissive_or_restrictive,
  CASE policy.polcmd
    WHEN 'r' THEN 'SELECT'
    WHEN 'a' THEN 'INSERT'
    WHEN 'w' THEN 'UPDATE'
    WHEN 'd' THEN 'DELETE'
    WHEN '*' THEN 'ALL'
  END as command
FROM pg_policy policy
JOIN pg_class target_table ON policy.polrelid = target_table.oid
JOIN pg_namespace policynamespace ON target_table.relnamespace = policynamespace.oid
WHERE target_table.relname = 'profiles';

-- Check for foreign key constraints on profiles
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM
  information_schema.table_constraints AS tc
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE
  tc.constraint_type = 'FOREIGN KEY'
  AND (tc.table_name = 'profiles' OR ccu.table_name = 'profiles');

-- Check for any active connections that might be causing locks
SELECT 
  pid,
  usename, 
  state, 
  query,
  query_start
FROM 
  pg_stat_activity 
WHERE 
  usename = 'postgres' 
  AND state = 'active'; 