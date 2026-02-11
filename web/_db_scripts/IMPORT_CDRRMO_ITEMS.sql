-- ============================================================================
-- IMPORT CDRRMO ITEMS SCRIPT (WITH DESCRIPTIONS)
-- ============================================================================
-- 1. Ensure description column exists (Safe Check)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'description') THEN 
        ALTER TABLE inventory ADD COLUMN description TEXT;
    END IF;
END $$;

-- 2. Insert Items
INSERT INTO inventory (item_name, category, description, stock_total, stock_available, status) VALUES
-- OFFICE
('Modular Conference Table', 'Office', 'Size: 0.8w / 4.60l x 0.75H, Box Base leg', 1, 1, 'Good'),
('Office Table', 'Office', 'Standard Office Table', 1, 1, 'Good'),
('Visitor Chair', 'Office', 'Standard Visitor Chair', 1, 1, 'Good'),
('Workstation Chair', 'Office', 'Ergonomic Workstation Chair', 1, 1, 'Good'),
('White Board', 'Office', '4 x 6 ft', 1, 1, 'Good'),
('Laminating Machine', 'Office', 'Heavy Duty (QUAFF)', 1, 1, 'Good'),

-- RESCUE - DIVING
('Diving Goggles', 'Rescue', 'Aquamundo, Tampered lenses, reduces distortion', 1, 1, 'Good'),
('Dive Finger Reel', 'Rescue', 'Plastic with Brass Bolt, Brand: SAEKODIVE', 1, 1, 'Good'),
('Hi-cut Boots (Small)', 'PPE', 'Brand: Sherwood', 1, 1, 'Good'),
('Hi-cut Boots (XL)', 'PPE', 'Brand: Sherwood', 1, 1, 'Good'),
('BCD Donut Style (L)', 'Rescue', 'Aquamundo, Large', 1, 1, 'Good'),
('BCD Donut Style (S)', 'Rescue', 'Aquamundo, Small', 1, 1, 'Good'),
('Diving Knife', 'Rescue', 'Stainless Steel, Brand: AKONA', 1, 1, 'Good'),
('Diving Flashlight', 'Rescue', 'Brand: Problue', 1, 1, 'Good'),
('Safety Tube', 'Rescue', '6ft, Brand: Sherwood', 1, 1, 'Good'),
('Diving Fins (S)', 'Rescue', 'Brand: Aquamundo', 1, 1, 'Good'),
('Diving Fins (XL)', 'Rescue', 'Brand: Aquamundo', 1, 1, 'Good'),
('Lift Bag', 'Rescue', '63kg, Orange, Brand: Sherwood', 1, 1, 'Good'),
('Diving Tank', 'Rescue', 'Aluminum 820cf/11.1 Ltr, Brand: Aquamundo', 1, 1, 'Good'),
('Regulator (2nd Stage)', 'Rescue', 'Brand: Sherwood Model: Brut', 1, 1, 'Good'),
('Wet Suit', 'Rescue', 'AQUALUNG, Heavy Duty non-corrosive YKK Zipper', 1, 1, 'Good'),

-- RESCUE - ROPES & HARDWARE
('Webbing Loop 120cm', 'Rescue', 'Brand: Petzl Model: Anneau 120', 1, 1, 'Good'),
('Webbing Loop 150cm', 'Rescue', 'Brand: Petzl Model: Anneau 150', 1, 1, 'Good'),
('Fixe Anchor Strap', 'Rescue', '200cm, Brand: Petzl-Connexion Fixe 200', 1, 1, 'Good'),
('Rescue-8 Alloy', 'Rescue', 'Brand: CT Model: Otto Rescue', 1, 1, 'Good'),
('Rescue Triangle', 'Rescue', 'Petzl, France', 1, 1, 'Good'),
('Dynamic Rope Lanyard', 'Rescue', '1.0 mtr, Non-adjustable, Brand: Petzl', 1, 1, 'Good'),
('Carabiner (Large)', 'Rescue', 'Brand: CT', 1, 1, 'Good'),
('Carabiner (Locking)', 'Rescue', 'Large D-Shape Alloy Screw, Petzl Volcan SL', 1, 1, 'Good'),
('Single Pulley', 'Rescue', 'Brand: Kong Model: Extra Roll', 1, 1, 'Good'),
('Double Pulley', 'Rescue', 'Brand: Kong Model: Twin', 1, 1, 'Good'),
('Rope Protector', 'Rescue', 'Articulated, Brand: Kong', 1, 1, 'Good'),
('Rigging Plate', 'Rescue', 'Anchor Plate, Brand: Kong', 1, 1, 'Good'),
('Descender (Stop)', 'Rescue', 'Self-braking w/ Anti-Panic, Brand: Petzl', 1, 1, 'Good'),
('Full Body Harness', 'Rescue', 'CT Model', 1, 1, 'Good'),
('Sit Harness', 'Rescue', 'Brand: CT Model: Avao', 1, 1, 'Good'),
('Rescue Waistbelt Bag', 'Rescue', 'Large Fabric, Petzl Transport 45L', 1, 1, 'Good'),
('Static Kernmantle Rope', 'Rescue', '12mm x 100m, Brand: Cousin Trestec', 1, 1, 'Good'),
('Prusik Cord 4mm', 'Rescue', '4mm x 100m, Cousin Trestec', 1, 1, 'Good'),
('Prusik Cord 7mm', 'Rescue', '7mm x 100m, Cousin Trestec/Tendon', 1, 1, 'Good'),

-- LOGISTICS & TOOLS
('Mop', 'Logistics', 'Wooden handle, HD', 1, 1, 'Good'),
('Pressure Washer', 'Tools', 'With pressure Hose, Brand: Kawasaki', 1, 1, 'Good'),
('Battery Pack', 'Comms', 'ICOM Ni-MH BP-210 7.2V 1650mAH', 1, 1, 'Good'),
('Air Stapler', 'Tools', 'Brand: DCA', 1, 1, 'Good'),
('Gun Tacker', 'Tools', 'Brand: ARROW', 1, 1, 'Good'),
('Welding Machine', 'Tools', 'INGCO Inverter 320A', 1, 1, 'Good'),
('Adjustable Wrench', 'Tools', 'STANLEY 32mm', 1, 1, 'Good'),
('Motor Grinder', 'Tools', '350 watts, BOSCH', 1, 1, 'Good'),
('Knapsack Sprayer', 'Logistics', 'Brand: Tungho, Capacity: 16 Ltrs', 1, 1, 'Good'),
('Lineman Pliers', 'Tools', 'Combination plier 9.5 CRESTON', 1, 1, 'Good'),
('Diagonal Pliers', 'Tools', '7 inch, CRESTON', 1, 1, 'Good'),
('Screwdriver Set', 'Tools', '6 pcs./set, Lotus', 1, 1, 'Good'),
('Megaphone', 'Comms', 'Heavy Duty', 1, 1, 'Good'),
('Vacuum Cleaner', 'Logistics', 'Heavy Duty, Lotus 6 gal.', 1, 1, 'Good'),
('Electric Impact Drill', 'Tools', 'With Adaptor, BOSCH', 1, 1, 'Good'),
('Air Compressor', 'Tools', '1HP, VESPA', 1, 1, 'Good'),
('Water Pump', 'Logistics', '6.5HP (gasoline), AKASHI EK-160', 1, 1, 'Good'),
('Sledge Hammer 10lbs', 'Tools', 'Heavy Duty', 1, 1, 'Good'),
('Crowbar 30"', 'Tools', 'Heavy Duty', 1, 1, 'Good'),
('Fire Extinguisher', 'PPE', 'Palmer', 1, 1, 'Good'),

-- MEDICAL
('Head Immobilizer', 'Medical', 'Made in China', 1, 1, 'Good'),
('Extrication Device', 'Medical', 'BODY SPLINT', 1, 1, 'Good'),
('AED Trainer', 'Medical', 'Red Cross', 1, 1, 'Good'),
('Spine Board', 'Medical', 'X-Ray Translucent', 1, 1, 'Good'),
('Pulse Oximeter', 'Medical', 'Adult, China', 1, 1, 'Good'),
('Cadaver Bag', 'Logistics', 'No Brand, PH Made', 1, 1, 'Good'),
('First Aid Box', 'Medical', 'Aluminum Alloy', 1, 1, 'Good'),
('Bag Valve Mask', 'Medical', 'Adult BVM (Topcare/Mdx)', 1, 1, 'Good'),
('BP Apparatus', 'Medical', 'Aneroid-Baxtel', 1, 1, 'Good')

ON CONFLICT DO NOTHING;
