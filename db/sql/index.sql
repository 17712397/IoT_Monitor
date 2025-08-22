-- 測定箇所
CREATE INDEX idx_locations_building_floor ON locations(building_id, floor);

-- タグデータ
CREATE INDEX idx_tags_building ON tags(building_id);
CREATE INDEX idx_tags_location ON tags(location_id);
CREATE INDEX idx_tags_measure_type ON tags(measure_type_id);
CREATE INDEX idx_tags_hierarchy ON tags(building_id, location_id, measure_type_id);

-- 測定データ
CREATE INDEX idx_measurements_tag_timestamp ON measurements(tag_id, timestamp DESC);

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
