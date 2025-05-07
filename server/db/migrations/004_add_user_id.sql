-- Add user_id column
ALTER TABLE public.ridez_rides 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Update RLS policies to check user_id
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.ridez_rides;
CREATE POLICY "Enable insert for authenticated users" ON public.ridez_rides
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.ridez_rides;
CREATE POLICY "Enable update for authenticated users" ON public.ridez_rides
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.ridez_rides;
CREATE POLICY "Enable delete for authenticated users" ON public.ridez_rides
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id); 