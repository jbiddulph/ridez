-- Drop existing policies
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON ridez.ridez;

-- Create separate policies for different operations
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