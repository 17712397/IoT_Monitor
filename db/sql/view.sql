-- 時間別集計ビュー
CREATE MATERIALIZED VIEW mv_hourly_aggregates AS
SELECT
    date_trunc('hour', m.timestamp) as hour,
    t.building_id,
    t.location_id,
    t.measure_type_id,
    l.floor,
    COUNT(*) as data_count,
    AVG(m.value) as avg_value,
    MIN(m.value) as min_value,
    MAX(m.value) as max_value,
    STDDEV(m.value) as stddev_value
FROM measurements m
JOIN tags t ON m.tag_id = t.tag_id
JOIN locations l ON t.location_id = l.location_id
GROUP BY
    date_trunc('hour', m.timestamp),
    t.building_id,
    t.location_id,
    t.measure_type_id,
    l.floor
WITH DATA;

-- インデックス追加
CREATE INDEX idx_mv_hourly_building ON mv_hourly_aggregates(building_id, hour DESC);
CREATE INDEX idx_mv_hourly_floor ON mv_hourly_aggregates(floor, hour DESC);
CREATE INDEX idx_mv_hourly_measure ON mv_hourly_aggregates(measure_type_id, hour DESC);

-- 日別集計ビュー
CREATE MATERIALIZED VIEW mv_daily_aggregates AS
SELECT
    date_trunc('day', m.timestamp) as day,
    t.building_id,
    b.building_name,
    l.location_id,
    l.location_name,
    l.floor,
    t.measure_type_id,
    mt.measure_type_name,
    mt.unit,
    COUNT(*) as data_count,
    AVG(m.value) as avg_value,
    MIN(m.value) as min_value,
    MAX(m.value) as max_value
FROM measurements m
JOIN tags t ON m.tag_id = t.tag_id
JOIN buildings b ON t.building_id = b.building_id
JOIN locations l ON t.location_id = l.location_id
JOIN measure_types mt ON t.measure_type_id = mt.measure_type_id
GROUP BY
    date_trunc('day', m.timestamp),
    t.building_id, b.building_name,
    l.location_id, l.location_name, l.floor,
    t.measure_type_id, mt.measure_type_name, mt.unit
WITH DATA;

CREATE INDEX idx_mv_daily_composite ON mv_daily_aggregates(building_id, floor, measure_type_id, day DESC);

-- BI用の統合ビュー
CREATE OR REPLACE VIEW v_bi_dashboard AS
SELECT
    b.building_name,
    l.floor,
    l.location_name,
    mt.measure_type_name,
    mt.unit,
    h.hour,
    h.avg_value,
    h.min_value,
    h.max_value,
    h.data_count
FROM mv_hourly_aggregates h
JOIN buildings b ON h.building_id = b.building_id
JOIN locations l ON h.location_id = l.location_id
JOIN measure_types mt ON h.measure_type_id = mt.measure_type_id;
-- WHERE h.hour >= CURRENT_DATE - interval '7 days';

-- リアルタイムダッシュボード用（直近データ）
CREATE OR REPLACE VIEW v_bi_realtime AS
WITH latest_data AS (
    SELECT
        tag_id,
        value,
        timestamp,
        ROW_NUMBER() OVER (PARTITION BY tag_id ORDER BY timestamp DESC) as rn
    FROM measurements
    WHERE timestamp >= CURRENT_TIMESTAMP - interval '1 hour'
)
SELECT
    b.building_name,
    l.floor,
    l.location_name,
    mt.measure_type_name,
    ld.value,
    ld.timestamp
FROM latest_data ld
JOIN tags t ON ld.tag_id = t.tag_id
JOIN buildings b ON t.building_id = b.building_id
JOIN locations l ON t.location_id = l.location_id
JOIN measure_types mt ON t.measure_type_id = mt.measure_type_id
WHERE ld.rn = 1;
