-- ============================================================================
-- LIGTAS SYSTEM - BULK INVENTORY REPLACEMENT
-- ============================================================================
-- 1. CLEAR OLD DATA
-- This removes all existing inventory and logs to ensure a clean start
TRUNCATE TABLE borrow_logs, inventory RESTART IDENTITY CASCADE;

-- 2. INSERT NEW DATA FROM THE UPDATED LIST
-- Categories assigned: Medical, Rescue, Logistics, PPE, Tools
INSERT INTO inventory (item_name, category, stock_total, stock_available, status) VALUES
('Oxygen Tank Large', 'Medical', 6, 6, 'Good'),
('Snake Hook & Snake Grab', 'Rescue', 3, 3, 'Good'),
('Life Vest', 'Rescue', 89, 89, 'Good'),
('Throw Bag', 'Rescue', 11, 11, 'Good'),
('Life Buoy', 'Rescue', 11, 11, 'Good'),
('Shovel', 'Rescue', 2, 2, 'Good'),
('Dibble (Tagad)', 'Rescue', 2, 2, 'Good'),
('Battery Charger', 'Tools', 3, 3, 'Good'),
('Triangular Bandage', 'Medical', 2, 2, 'Good'),
('Projector Set', 'Logistics', 5, 5, 'Good'),
('HDMI Cable', 'Logistics', 14, 14, 'Good'),
('Camping Chairs', 'Logistics', 2, 2, 'Good'),
('Stethoscope', 'Medical', 1, 1, 'Good'),
('Helmet Petzel Yellow', 'PPE', 1, 1, 'Good'),
('Folding Bed', 'Logistics', 15, 15, 'Good'),
('Megaphone (White/Blue)', 'Logistics', 1, 1, 'Good'),
('Thermometer', 'Medical', 1, 1, 'Good'),
('Oxygen Tank Large with Regulator', 'Medical', 4, 4, 'Good'),
('Stand Fan', 'Logistics', 8, 8, 'Good'),
('POC Radio #4', 'Logistics', 1, 1, 'Good'),
('Oxygen Tank Medium with Regulator', 'Medical', 4, 4, 'Good'),
('Electric Fan', 'Logistics', 3, 3, 'Good'),
('Life Jacket', 'Rescue', 38, 38, 'Good'),
('Life Rings', 'Rescue', 3, 3, 'Good'),
('Spin', 'Rescue', 1, 1, 'Good'),
('Nebulizer (Asclepius)', 'Medical', 5, 5, 'Good'),
('Scuba Tank', 'Rescue', 7, 7, 'Good'),
('Life Can', 'Rescue', 8, 8, 'Good'),
('Speaker', 'Logistics', 6, 6, 'Good'),
('New Born Weighing Scale', 'Medical', 1, 1, 'Good'),
('Microphone', 'Logistics', 1, 1, 'Good'),
('Projector Screen', 'Logistics', 6, 6, 'Good'),
('Adult Dummy', 'Medical', 1, 1, 'Good'),
('Folding Table', 'Logistics', 6, 6, 'Good'),
('Large Oxygen Tank with Regulator', 'Medical', 2, 2, 'Good'),
('Boots', 'PPE', 2, 2, 'Good'),
('Projector', 'Logistics', 2, 2, 'Good'),
('Tubular Rope (10m)', 'Rescue', 1, 1, 'Good'),
('Carabiner', 'Rescue', 1, 1, 'Good'),
('Flashlight', 'Rescue', 2, 2, 'Good'),
('Axe', 'Rescue', 1, 1, 'Good'),
('Crowbar', 'Rescue', 1, 1, 'Good'),
('Pick Mattack (Piko)', 'Rescue', 1, 1, 'Good'),
('Sledge Hammer', 'Rescue', 1, 1, 'Good'),
('Jack Hammer', 'Rescue', 5, 5, 'Good'),
('Red Coller', 'PPE', 1, 1, 'Good'),
('Paper Cutter', 'Logistics', 1, 1, 'Good'),
('Hand Drill', 'Tools', 2, 2, 'Good'),
('Drill Bits', 'Tools', 3, 3, 'Good'),
('Oxygen Tank Medium', 'Medical', 4, 4, 'Good'),
('Chainsaw (Small)', 'Rescue', 1, 1, 'Good'),
('Nebulizer (Extra)', 'Medical', 1, 1, 'Good'),
('Nebulizer', 'Medical', 2, 2, 'Good'),
('Foot Pump', 'Rescue', 1, 1, 'Good'),
('BP Apparatus', 'Medical', 2, 2, 'Good'),
('Glucometer (Raphael)', 'Medical', 1, 1, 'Good'),
('Crocodile Jack', 'Rescue', 2, 2, 'Good'),
('Oxygen Regulator', 'Medical', 2, 2, 'Good'),
('Pulse Oximeter', 'Medical', 1, 1, 'Good'),
('Sphygmomanometer', 'Medical', 1, 1, 'Good');

-- ============================================================================
-- NOTE: 
-- 1. All duplicates in the text list were aggregated by name.
-- 2. Status defaults to 'Good' as per standard audit.
-- 3. Run this script in the Supabase SQL Editor to apply changes.
-- ============================================================================
