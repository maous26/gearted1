-- Sample data for gear compatibility system testing
-- This includes realistic airsoft equipment data

-- Insert manufacturers
INSERT INTO manufacturers (name, brand_code, country) VALUES
('Tokyo Marui', 'TM', 'Japan'),
('G&G Armament', 'GG', 'Taiwan'),
('Classic Army', 'CA', 'Hong Kong'),
('Krytac', 'KRY', 'USA'),
('VFC', 'VFC', 'Taiwan'),
('CYMA', 'CYMA', 'China'),
('Lancer Tactical', 'LT', 'USA'),
('ASG', 'ASG', 'Denmark'),
('WE Tech', 'WE', 'Taiwan'),
('KWA', 'KWA', 'USA');

-- Insert equipment types
INSERT INTO equipment_types (name, code) VALUES
('Airsoft Rifles', 'RIFLE'),
('Airsoft Pistols', 'PISTOL'),
('Accessories', 'ACC'),
('Magazines', 'MAG'),
('Optics', 'OPTIC'),
('Batteries', 'BAT'),
('Parts', 'PART');

-- Insert equipment categories
INSERT INTO equipment_categories (name, code, type_id, standard) VALUES
-- Rifles
('AEG Assault Rifles', 'AEG_AR', 1, 'AEG'),
('Gas Blowback Rifles', 'GBB_R', 1, 'GBB'),
('Spring Sniper Rifles', 'SPR_SR', 1, 'Spring'),
('AEG SMGs', 'AEG_SMG', 1, 'AEG'),
-- Pistols
('Gas Blowback Pistols', 'GBB_P', 2, 'GBB'),
('AEP Electric Pistols', 'AEP', 2, 'AEG'),
-- Magazines
('AEG Rifle Magazines', 'MAG_AEG_R', 4, 'AEG'),
('GBB Rifle Magazines', 'MAG_GBB_R', 4, 'GBB'),
('Pistol Magazines', 'MAG_P', 4, 'GBB'),
-- Batteries
('LiPo Batteries', 'BAT_LIPO', 6, 'LiPo'),
('NiMH Batteries', 'BAT_NIMH', 6, 'NiMH'),
-- Optics
('Red Dot Sights', 'OPTIC_RDS', 5, 'Picatinny'),
('Scopes', 'OPTIC_SCOPE', 5, 'Picatinny');

-- Insert sample equipment
INSERT INTO equipment (name, model, manufacturer_id, category_id, sku, weight, length, power_source, price_range, image_url) VALUES
-- Tokyo Marui AEGs
('M4A1 SOPMOD', 'TM-M4A1-SOPMOD', 1, 1, 'TM001', 2800, 840, 'AEG Battery', '$400-500', 'https://example.com/tm-m4a1.jpg'),
('AK74', 'TM-AK74', 1, 1, 'TM002', 3200, 940, 'AEG Battery', '$350-450', 'https://example.com/tm-ak74.jpg'),
('MP5A5', 'TM-MP5A5', 1, 4, 'TM003', 2400, 660, 'AEG Battery', '$300-400', 'https://example.com/tm-mp5.jpg'),

-- G&G Equipment
('CM16 Raider', 'GG-CM16-RAIDER', 2, 1, 'GG001', 2600, 820, 'AEG Battery', '$150-250', 'https://example.com/gg-cm16.jpg'),
('G26', 'GG-G26', 2, 5, 'GG002', 680, 180, 'Green Gas', '$80-120', 'https://example.com/gg-g26.jpg'),

-- Krytac
('Trident CRB', 'KRY-TRIDENT-CRB', 4, 1, 'KRY001', 2900, 770, 'AEG Battery', '$350-450', 'https://example.com/kry-trident.jpg'),

-- Magazines
('M4 Hi-Cap Magazine', 'TM-M4-HICAP', 1, 7, 'TM-MAG001', 150, NULL, NULL, '$15-25', NULL),
('AK Hi-Cap Magazine', 'TM-AK-HICAP', 1, 7, 'TM-MAG002', 180, NULL, NULL, '$18-28', NULL),
('G26 Magazine', 'GG-G26-MAG', 2, 9, 'GG-MAG001', 120, NULL, 'Green Gas', '$25-35', NULL),

-- Batteries
('7.4V 1200mAh LiPo', 'GENERIC-LIPO-74-1200', 8, 10, 'BAT001', 95, NULL, NULL, '$20-30', NULL),
('8.4V 1600mAh NiMH', 'GENERIC-NIMH-84-1600', 8, 11, 'BAT002', 180, NULL, NULL, '$15-25', NULL),

-- Optics
('T1 Red Dot Sight', 'GENERIC-T1-RDS', 8, 12, 'OPT001', 280, NULL, 'Battery', '$50-80', NULL),
('4x32 ACOG Scope', 'GENERIC-ACOG-4X32', 8, 13, 'OPT002', 520, NULL, NULL, '$100-150', NULL);

-- Insert compatibility rules
INSERT INTO compatibility_rules (source_equipment_id, target_equipment_id, compatibility_type, compatibility_score, notes) VALUES
-- M4A1 SOPMOD compatibilities
(1, 7, 'magazine', 95, 'Perfect fit - same manufacturer M4 platform'),
(1, 10, 'battery', 90, 'Standard 7.4V LiPo compatible with most AEGs'),
(1, 11, 'battery', 85, 'NiMH works but LiPo preferred for performance'),
(1, 12, 'optic', 92, 'Picatinny rail compatible'),
(1, 13, 'optic', 88, 'Compatible but may need riser for proper sight picture'),

-- AK74 compatibilities  
(2, 8, 'magazine', 95, 'Perfect fit - same manufacturer AK platform'),
(2, 10, 'battery', 90, 'Standard 7.4V LiPo compatible'),
(2, 11, 'battery', 85, 'NiMH compatible'),
(2, 12, 'optic', 75, 'Requires AK rail mount adapter'),

-- MP5A5 compatibilities
(3, 10, 'battery', 88, '7.4V LiPo compatible with MP5 gearbox'),
(3, 11, 'battery', 82, 'NiMH compatible but space constraints'),
(3, 12, 'optic', 85, 'Compatible with MP5 rail systems'),

-- CM16 Raider compatibilities
(4, 7, 'magazine', 85, 'M4 magazines compatible but different brand'),
(4, 10, 'battery', 92, 'Excellent compatibility with standard LiPo'),
(4, 11, 'battery', 88, 'NiMH compatible'),
(4, 12, 'optic', 90, 'Standard Picatinny compatibility'),

-- G26 Pistol compatibilities
(5, 9, 'magazine', 95, 'Perfect fit - same manufacturer'),

-- Cross-platform magazine compatibility
(1, 8, 'magazine', 15, 'Incompatible - M4 cannot use AK magazines'),
(2, 7, 'magazine', 15, 'Incompatible - AK cannot use M4 magazines'),
(4, 8, 'magazine', 15, 'Incompatible - M4 platform cannot use AK magazines');

-- Add some analytics data for testing
INSERT INTO compatibility_analytics (source_equipment_id, target_equipment_id, user_id, source, session_id, created_at) VALUES
(1, 7, 'user123', 'WEB', 'session_001', NOW() - INTERVAL '1 day'),
(1, 10, 'user456', 'API', 'session_002', NOW() - INTERVAL '2 hours'),
(2, 8, 'user789', 'WEB', 'session_003', NOW() - INTERVAL '30 minutes'),
(4, 12, NULL, 'API', 'anonymous_001', NOW() - INTERVAL '10 minutes');
