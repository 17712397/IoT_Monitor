-- 2024年から2030年までの月単位パーティション作成
DO $$
DECLARE
    v_year INT;
    v_month INT;
    v_start_date DATE;
    v_end_date DATE;
    v_partition_name TEXT;
    v_count INT := 0;
BEGIN
    -- 既存のmeasurementsテーブルがない場合は作成
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables
        WHERE tablename = 'measurements'
    ) THEN
        CREATE TABLE measurements (
            timestamp TIMESTAMPTZ NOT NULL,
            tag_id INT NOT NULL,
            value DOUBLE PRECISION NOT NULL,
            CONSTRAINT measurements_unique_timestamp_tag UNIQUE (timestamp, tag_id)
        ) PARTITION BY RANGE (timestamp);

        RAISE NOTICE 'Created parent table: measurements';
    END IF;

    -- 2024年から2030年まで
    FOR v_year IN 2024..2030 LOOP
        FOR v_month IN 1..12 LOOP
            -- 開始日と終了日を計算
            v_start_date := DATE(v_year || '-' || LPAD(v_month::TEXT, 2, '0') || '-01');
            v_end_date := (v_start_date + INTERVAL '1 month')::DATE;

            -- パーティション名
            v_partition_name := 'measurements_' || v_year || '_' || LPAD(v_month::TEXT, 2, '0');

            -- パーティション作成
            BEGIN
                EXECUTE format('
                    CREATE TABLE %I PARTITION OF measurements
                    FOR VALUES FROM (%L) TO (%L)',
                    v_partition_name, v_start_date, v_end_date
                );

                v_count := v_count + 1;
                RAISE NOTICE 'Created partition: % (% to %)',
                    v_partition_name, v_start_date, v_end_date;

            EXCEPTION
                WHEN duplicate_table THEN
                    RAISE NOTICE 'Partition already exists: %', v_partition_name;
            END;

        END LOOP;
    END LOOP;

    RAISE NOTICE '=================================';
    RAISE NOTICE 'Total partitions created: %', v_count;
    RAISE NOTICE 'Period: 2024-01 to 2030-12';
    RAISE NOTICE '=================================';
END $$;
