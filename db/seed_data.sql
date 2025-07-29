-- 建屋データ挿入
INSERT INTO buildings (building_code, building_name) VALUES
    ('LOG_code', 'LOG_name'),
    ('RD_code', 'RD_name'),
    ('QC_code', 'QC_name');

-- 測定種データ挿入
INSERT INTO measure_types (measure_type_code, measure_type_name, unit, min_valid_value, max_valid_value) VALUES
    ('TEMP_code', 'TEMP_name', 'degree_celsius', -50, 100),
    ('HUMID_code', 'HUMID_name', '%', 0, 100),
    ('POWER_code', 'POWER_name', 'kW', 0, 10000);

-- 測定場所データ挿入
INSERT INTO locations (building_id, location_code, location_name, floor_number) VALUES
    (1, 'LOG_1F_01_code', 'LOG_1F_01_name', 1),
    (1, 'LOG_2F_01_code', 'LOG_2F_01_name', 2),
    (2, 'RD_1F_01_code', 'RD_1F_01_name', 1),
    (2, 'RD_2F_01_code', 'RD_2F_01_name', 2),
    (3, 'QC_1F_01_code', 'QC_1F_01_name', 1),
    (3, 'QC_2F_01_code', 'QC_2F_01_name', 2);
