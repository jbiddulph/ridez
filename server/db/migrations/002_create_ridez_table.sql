-- Create ridez table
CREATE TABLE IF NOT EXISTS ridez.ridez (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Grant access to the table
GRANT ALL ON ridez.ridez TO authenticated;
GRANT ALL ON ridez.ridez TO anon;

-- Enable RLS
ALTER TABLE ridez.ridez ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable read access for all users" ON ridez.ridez;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON ridez.ridez;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON ridez.ridez;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON ridez.ridez;

-- Create policies
CREATE POLICY "Enable read access for all users" ON ridez.ridez
    FOR SELECT
    USING (true);

CREATE POLICY "Enable insert for authenticated users" ON ridez.ridez
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON ridez.ridez
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable delete for authenticated users" ON ridez.ridez
    FOR DELETE
    TO authenticated
    USING (true); 