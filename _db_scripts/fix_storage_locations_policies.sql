-- Fix storage_locations RLS policies

-- Drop all existing policies
DROP POLICY IF EXISTS "Allow authenticated users to read storage locations" ON storage_locations;
DROP POLICY IF EXISTS "Allow authenticated users to insert storage locations" ON storage_locations;
DROP POLICY IF EXISTS "Allow authenticated users to delete storage locations" ON storage_locations;
DROP POLICY IF EXISTS "Allow authenticated users full access to storage locations" ON storage_locations;

-- Create single policy for all operations
CREATE POLICY "Allow authenticated users full access to storage locations"
    ON storage_locations
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Ensure proper grants
GRANT ALL ON storage_locations TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE storage_locations_id_seq TO authenticated;
