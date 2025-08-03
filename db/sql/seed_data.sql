-- 建屋データ挿入
INSERT INTO buildings (building_name) VALUES
    ('LOG'),
    ('RD'),
    ('QC');

-- 測定箇所データ挿入
INSERT INTO locations (building_id, location_name, floor_number) VALUES
    (1, 'GENZAIRYO', 6),
    (1, 'DOKUGEKI', 6),
    (1, 'M1', 5),
    (1, 'M2', 5);

-- 測定種データ挿入
INSERT INTO measure_types (measure_type_name, unit) VALUES
    ('TEMPERATURE', 'C'),
    ('HUMID', '%'),
    ('POWER', 'W'),
    ('I_POWER', 'Wh');

-- タグデータ挿入
INSERT INTO tags (building_id, location_id, measure_type_id, tag_code, min_value, max_value) VALUES
    (1, 1, 1, 'Tag0059', 0, 100),
    (1, 1, 2, 'Tag0058', 0, 100),
    (1, 2, 1, 'Tag0061', 0, 100),
    (1, 2, 2, 'Tag0060', 0, 100),
    (1, 3, 3, 'Tag0019', 0, 1000),
    (1, 3, 4, 'Tag0020', 0, 10000),
    (1, 4, 3, 'Tag0009', 0, 1000),
    (1, 4, 4, 'Tag0010', 0, 10000);