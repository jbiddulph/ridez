-- Create routes table
CREATE TABLE public.ridez_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    ride_id UUID REFERENCES public.ridez_rides(id),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    distance_from_last_point DOUBLE PRECISION,
    sequence_number INTEGER NOT NULL
);

-- Grant access to the table
GRANT ALL ON public.ridez_routes TO authenticated;
GRANT ALL ON public.ridez_routes TO anon;
GRANT ALL ON public.ridez_routes TO service_role;

-- Enable RLS
ALTER TABLE public.ridez_routes ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users" ON public.ridez_routes
    FOR SELECT
    USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.ridez_routes
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable update for authenticated users" ON public.ridez_routes
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable delete for authenticated users" ON public.ridez_routes
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id); 