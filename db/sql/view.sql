-- BI可視化用ビュー
CREATE OR REPLACE VIEW v_measurements_bi AS
SELECT 
    m.timestamp,
    b.building_name,
    l.location_name,
    l.floor_number,
    mt.measure_type_name,
    m.value,
    t.min_value,
    t.max_value,
    t.tag_code,
    mt.unit,
    CASE 
        WHEN m.value < t.min_value THEN '下限値違反'
        WHEN m.value > t.max_value THEN '上限値違反'
        ELSE '正常'
    END as status,
    CASE 
        WHEN m.value < t.min_value OR m.value > t.max_value THEN TRUE
        ELSE FALSE
    END as is_alert
FROM measurements m
INNER JOIN tags t ON m.tag_id = t.tag_id
INNER JOIN buildings b ON t.building_id = b.building_id
INNER JOIN locations l ON t.location_id = l.location_id
INNER JOIN measure_types mt ON t.measure_type_id = mt.measure_type_id
ORDER BY m.timestamp DESC, b.building_name, l.location_name, mt.measure_type_name;

CREATE INDEX IF NOT EXISTS idx_measurements_timestamp_desc ON measurements(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_tags_relations ON tags(tag_id, building_id, location_id, measure_type_id);