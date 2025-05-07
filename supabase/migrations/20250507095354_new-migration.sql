-- First, let's ensure the table structure is correct
DROP TABLE IF EXISTS public.ridez_routes;
DROP TABLE IF EXISTS public.ridez_rides;

-- Create the rides table
CREATE TABLE public.ridez_rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    title TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create the routes table
CREATE TABLE public.ridez_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    ride_id UUID REFERENCES public.ridez_rides(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    distance_from_last_point DOUBLE PRECISION,
    sequence_number INTEGER NOT NULL
);

-- Grant explicit permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;
GRANT ALL ON public.ridez_rides TO authenticated;
GRANT ALL ON public.ridez_rides TO anon;
GRANT ALL ON public.ridez_rides TO service_role;
GRANT ALL ON public.ridez_routes TO authenticated;
GRANT ALL ON public.ridez_routes TO anon;
GRANT ALL ON public.ridez_routes TO service_role;

-- Temporarily disable RLS for debugging
ALTER TABLE public.ridez_rides DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ridez_routes DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.ridez_rides;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.ridez_rides;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.ridez_rides;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.ridez_rides;
DROP POLICY IF EXISTS "Enable all operations for authenticated users" ON public.ridez_rides;

-- Create a single, simple policy for all operations on ridez_rides
CREATE POLICY "Allow all operations for authenticated users" ON public.ridez_rides
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Create a policy for anonymous users to read ridez_rides
CREATE POLICY "Allow anonymous users to read" ON public.ridez_rides
    FOR SELECT
    TO anon
    USING (true);

-- Create policies for ridez_routes
CREATE POLICY "Allow all operations for authenticated users" ON public.ridez_routes
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow anonymous users to read routes" ON public.ridez_routes
    FOR SELECT
    TO anon
    USING (true);
