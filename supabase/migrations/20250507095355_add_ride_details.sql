-- Drop existing constraints if they exist
ALTER TABLE public.ridez_rides 
DROP CONSTRAINT IF EXISTS ridez_rides_transport_type_check,
DROP CONSTRAINT IF EXISTS ridez_rides_transaction_type_check;

-- Add new columns to ridez_rides table with explicit constraints
ALTER TABLE public.ridez_rides
ADD COLUMN IF NOT EXISTS end_time TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS transport_type TEXT,
ADD COLUMN IF NOT EXISTS transaction_type TEXT,
ADD COLUMN IF NOT EXISTS amount DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add explicit constraints
ALTER TABLE public.ridez_rides
ADD CONSTRAINT ridez_rides_transport_type_check 
CHECK (transport_type IS NULL OR transport_type = ANY(ARRAY['walk'::text, 'cycle'::text, 'drive'::text]));

ALTER TABLE public.ridez_rides
ADD CONSTRAINT ridez_rides_transaction_type_check 
CHECK (transaction_type IS NULL OR transaction_type = ANY(ARRAY['spending'::text, 'earning'::text])); 