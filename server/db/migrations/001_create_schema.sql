-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS ridez;

-- Grant usage on schema to authenticated users
GRANT USAGE ON SCHEMA ridez TO authenticated;
GRANT USAGE ON SCHEMA ridez TO anon; 