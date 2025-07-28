-- 必要あれば

-- 古いデータのアーカイブ
INSERT INTO measurements_archive (timestamp, building_id, location_id, measure_type_id, value)
SELECT timestamp, building_id, location_id, measure_type_id, value
FROM measurements
WHERE timestamp < CURRENT_DATE - INTERVAL '2 years';

-- 古いデータの削除
DELETE FROM measurements
WHERE timestamp < CURRENT_DATE - INTERVAL '2 years';
