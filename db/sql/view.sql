SET CLIENT_ENCODING TO 'UTF8';
-- =========================
-- マテリアライズド・ビュー
-- =========================
-- 温度
CREATE MATERIALIZED VIEW mv_temp_1min AS
SELECT
    DATE_TRUNC('1 minutes', m.timestamp) AS time_bucket,
    t.building_id,
    l.location_id,
    l.floor,
    t.measure_type_id,
    mt.measure_type_name,
    AVG(m.value) AS avg_value,
    MIN(m.value) AS min_value,
    MAX(m.value) AS max_value,
    COUNT(*) AS sample_count,
    STDDEV(m.value) AS stddev_value
FROM measurements m
JOIN tags t ON m.tag_id = t.tag_id
JOIN locations l ON t.location_id = l.location_id
JOIN measure_types mt ON t.measure_type_id = mt.measure_type_id
WHERE
    t.is_active = TRUE
    AND mt.measure_type_name IN ('温度')
    AND m.timestamp >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1, 2, 3, 4, 5, 6
WITH DATA;

CREATE MATERIALIZED VIEW mv_temp_5min AS
SELECT
    DATE_TRUNC('5 minutes', m.timestamp) AS time_bucket,
    t.building_id,
    l.location_id,
    l.floor,
    t.measure_type_id,
    mt.measure_type_name,
    AVG(m.value) AS avg_value,
    MIN(m.value) AS min_value,
    MAX(m.value) AS max_value,
    COUNT(*) AS sample_count,
    STDDEV(m.value) AS stddev_value
FROM measurements m
JOIN tags t ON m.tag_id = t.tag_id
JOIN locations l ON t.location_id = l.location_id
JOIN measure_types mt ON t.measure_type_id = mt.measure_type_id
WHERE
    t.is_active = TRUE
    AND mt.measure_type_name IN ('温度')
    AND m.timestamp >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1, 2, 3, 4, 5, 6
WITH DATA;

-- 湿度
CREATE MATERIALIZED VIEW mv_humid_5min AS
SELECT
    DATE_TRUNC('10 minutes', m.timestamp) AS time_bucket,
    t.building_id,
    l.location_id,
    l.floor,
    t.measure_type_id,
    mt.measure_type_name,
    AVG(m.value) AS avg_value,
    MIN(m.value) AS min_value,
    MAX(m.value) AS max_value,
    COUNT(*) AS sample_count,
    STDDEV(m.value) AS stddev_value
FROM measurements m
JOIN tags t ON m.tag_id = t.tag_id
JOIN locations l ON t.location_id = l.location_id
JOIN measure_types mt ON t.measure_type_id = mt.measure_type_id
WHERE
    t.is_active = TRUE
    AND mt.measure_type_name IN ('湿度')
    AND m.timestamp >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1, 2, 3, 4, 5, 6
WITH DATA;

-- 電力
CREATE MATERIALIZED VIEW mv_power_1min AS
SELECT
    DATE_TRUNC('1 minutes', m.timestamp) AS time_bucket,
    t.building_id,
    l.location_id,
    l.floor,
    t.measure_type_id,
    mt.measure_type_name,
    AVG(m.value) AS avg_value,
    MIN(m.value) AS min_value,
    MAX(m.value) AS max_value,
    COUNT(*) AS sample_count,
    STDDEV(m.value) AS stddev_value
FROM measurements m
JOIN tags t ON m.tag_id = t.tag_id
JOIN locations l ON t.location_id = l.location_id
JOIN measure_types mt ON t.measure_type_id = mt.measure_type_id
WHERE
    t.is_active = TRUE
    AND mt.measure_type_name IN ('電力')
    AND m.timestamp >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1, 2, 3, 4, 5, 6
WITH DATA;

-- 積算電力
CREATE MATERIALIZED VIEW mv_integrated_power_30min AS
WITH ranked_data AS (
    SELECT
        DATE_TRUNC('30 minutes', m.timestamp) AS half_hour_bucket,
        t.building_id,
        l.location_id,
        l.floor,
        t.tag_id,
        m.value,
        m.timestamp,
        EXTRACT(DAY FROM m.timestamp) AS day_of_month,
        ROW_NUMBER() OVER (
            PARTITION BY DATE_TRUNC('30 minutes', m.timestamp), t.tag_id
            ORDER BY m.timestamp DESC
        ) AS rn
    FROM measurements m
    JOIN tags t ON m.tag_id = t.tag_id
    JOIN locations l ON t.location_id = l.location_id
    JOIN measure_types mt ON t.measure_type_id = mt.measure_type_id
    WHERE
        t.is_active = TRUE
        AND mt.measure_type_name = '積算電力'
        AND m.timestamp >= CURRENT_DATE - INTERVAL '2 years'
)
SELECT
    half_hour_bucket,
    building_id,
    location_id,
    floor,
    tag_id,
    value AS last_value,
    timestamp AS last_timestamp,
    CASE
        WHEN LAG(value) OVER (
            PARTITION BY building_id, location_id, tag_id
            ORDER BY half_hour_bucket
        ) > value
        THEN TRUE
        ELSE FALSE
    END AS monthly_reset
FROM ranked_data
WHERE rn = 1
WITH DATA;

-- =========================
-- ビュー
-- =========================
CREATE OR REPLACE VIEW v_bi_dashboard AS
-- 温度
SELECT
    time_bucket,
    building_id,
    location_id,
    floor,
    '温度' AS data_type,
    avg_value AS value,
    min_value,
    max_value,
    sample_count
    FROM mv_temp_1min
WHERE measure_type_name = '温度'
UNION ALL

SELECT
    time_bucket,
    building_id,
    location_id,
    floor,
    '温度' AS data_type,
    avg_value AS value,
    min_value,
    max_value,
    sample_count
    FROM mv_temp_5min
WHERE measure_type_name = '温度'
UNION ALL

-- 湿度
SELECT
    time_bucket,
    building_id,
    location_id,
    floor,
    '湿度' AS data_type,
    avg_value AS value,
    min_value,
    max_value,
    sample_count
FROM mv_humid_5min
WHERE measure_type_name = '湿度'
UNION ALL

-- 電力
SELECT
    time_bucket,
    building_id,
    location_id,
    floor,
    '電力' AS data_type,
    avg_value AS value,
    min_value,
    max_value,
    sample_count
FROM mv_power_1min
WHERE measure_type_name = '電力'
UNION ALL

-- 積算電力
SELECT
    half_hour_bucket AS time_bucket,
    building_id,
    location_id,
    floor,
    '積算電力' AS data_type,
    last_value AS value,
    last_value AS min_value,
    last_value AS max_value,
    1 AS sample_count
FROM mv_integrated_power_30min;
