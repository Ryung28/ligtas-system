-- Create storage_locations table for storing custom location presets
CREATE TABLE IF NOT EXISTS storage_locations (
    id BIGSERIAL PRIMARY KEY,
    location_name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE storage_locations ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all authenticated users full access (read, insert, delete)
CREATE POLICY "Allow authenticated users full access to storage locations"
    ON storage_locations
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Insert predefined locations
INSERT INTO storage_locations (location_name) VALUES
    ('Lower Warehouse'),
    ('2nd Floor Warehouse'),
    ('Office'),
    ('Field')
ON CONFLICT (location_name) DO NOTHING;

-- Grant permissions
GRANT ALL ON storage_locations TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE storage_locations_id_seq TO authenticated;
