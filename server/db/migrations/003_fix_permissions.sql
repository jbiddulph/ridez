-- Drop existing table if it exists
DROP TABLE IF EXISTS ridez.ridez;
DROP TABLE IF EXISTS public.ridez;
DROP TABLE IF EXISTS public.ridez_rides;

-- Create table in public schema with ridez_ prefix
CREATE TABLE public.ridez_rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Grant access to the table
GRANT ALL ON public.ridez_rides TO authenticated;
GRANT ALL ON public.ridez_rides TO anon;
GRANT ALL ON public.ridez_rides TO service_role;

-- Enable RLS
ALTER TABLE public.ridez_rides ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable read access for all users" ON public.ridez_rides;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.ridez_rides;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.ridez_rides;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.ridez_rides;

-- Create policies
CREATE POLICY "Enable read access for all users" ON public.ridez_rides
    FOR SELECT
    USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.ridez_rides
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.ridez_rides
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable delete for authenticated users" ON public.ridez_rides
    FOR DELETE
    TO authenticated
    USING (true); 