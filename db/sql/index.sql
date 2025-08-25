-- =========================
-- テーブル
-- =========================
-- 測定箇所
CREATE INDEX idx_locations_building_floor ON locations(building_id, floor);
-- タグ
CREATE INDEX idx_tags_building ON tags(building_id);
CREATE INDEX idx_tags_location ON tags(location_id);
CREATE INDEX idx_tags_measure_type ON tags(measure_type_id);
CREATE INDEX idx_tags_hierarchy ON tags(building_id, location_id, measure_type_id);
-- 測定
CREATE INDEX idx_measurements_tag_timestamp ON measurements(tag_id, timestamp DESC);

-- =========================
-- パーティションテーブル
-- =========================
-- 測定
DO $$
DECLARE
    partition_name TEXT;
BEGIN
    FOR partition_name IN
        SELECT tablename FROM pg_tables
        WHERE tablename LIKE 'measurements_20%'
    LOOP
        EXECUTE format('
            CREATE INDEX IF NOT EXISTS idx_%I_tag_timestamp
            ON %I (tag_id, timestamp DESC)',
            partition_name, partition_name
        );
        RAISE NOTICE 'Created index for %', partition_name;
    END LOOP;
END $$;

-- =========================
-- マテリアライズド・ビュー
-- =========================
-- 温度
CREATE INDEX idx_mv_temp_1min_time ON mv_temp_1min(time_bucket DESC, building_id, measure_type_id);
CREATE INDEX idx_mv_temp_1min_building ON mv_temp_1min(building_id, floor, time_bucket DESC);
CREATE INDEX idx_mv_temp_5min_time ON mv_temp_5min(time_bucket DESC, building_id, measure_type_id);
CREATE INDEX idx_mv_temp_5min_building ON mv_temp_5min(building_id, floor, time_bucket DESC);
-- 湿度
CREATE INDEX idx_mv_humid_5min_time ON mv_humid_5min(time_bucket DESC, building_id, measure_type_id);
CREATE INDEX idx_mv_humid_5min_building ON mv_humid_5min(building_id, floor, time_bucket DESC);
-- 電力
CREATE INDEX idx_mv_power_1min_time ON mv_power_1min(time_bucket DESC, building_id, measure_type_id);
CREATE INDEX idx_mv_power_1min_building ON mv_power_1min(building_id, floor, time_bucket DESC);
-- 積算電力
CREATE INDEX idx_mv_integrated_power_30min_time ON mv_integrated_power_30min(half_hour_bucket DESC, building_id);
