-- 建屋
DROP TABLE IF EXISTS buildings CASCADE;
CREATE TABLE buildings (
    building_id SERIAL PRIMARY KEY,
    building_code VARCHAR(20) NOT NULL UNIQUE,
    building_name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 測定箇所
DROP TABLE IF EXISTS locations CASCADE;
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    building_id INT NOT NULL REFERENCES buildings(building_id) ON DELETE CASCADE,
    location_code VARCHAR(50) NOT NULL,
    location_name TEXT NOT NULL,
    floor_number INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (building_id, location_code)
);

-- 測定種
DROP TABLE IF EXISTS measure_types CASCADE;
CREATE TABLE measure_types (
    measure_type_id SERIAL PRIMARY KEY,
    measure_type_code VARCHAR(20) NOT NULL UNIQUE,
    measure_type_name TEXT NOT NULL,
    unit VARCHAR(20) NOT NULL,
    min_valid_value DECIMAL(10, 3),
    max_valid_value DECIMAL(10, 3),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 測定データ
DROP TABLE IF EXISTS measurements CASCADE;
CREATE TABLE measurements (
    timestamp TIMESTAMPTZ NOT NULL,
    building_id INT NOT NULL,
    location_id INT NOT NULL,
    measure_type_id INT NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    CONSTRAINT measurements_pkey PRIMARY KEY (timestamp, building_id, location_id, measure_type_id),
    CONSTRAINT fk_building FOREIGN KEY (building_id) REFERENCES buildings(building_id),
    CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_measure_type FOREIGN KEY (measure_type_id) REFERENCES measure_types(measure_type_id)
) PARTITION BY LIST (building_id);

-- 測定データ_アーカイブ
DROP TABLE IF EXISTS measurements_archive CASCADE;
CREATE TABLE measurements_archive (
    timestamp TIMESTAMPTZ NOT NULL,
    building_id INT NOT NULL,
    location_id INT NOT NULL,
    measure_type_id INT NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    archive_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (timestamp, building_id, location_id, measure_type_id)
) PARTITION BY LIST (building_id);

-- 建屋パーティション_配送センター
CREATE TABLE measurements_building_1 PARTITION OF measurements
    FOR VALUES IN (1) PARTITION BY RANGE(timestamp);

-- 建屋パーティション_研究棟
CREATE TABLE measurements_building_2 PARTITION OF measurements
    FOR VALUES IN (2) PARTITION BY RANGE(timestamp);

-- 建屋パーティション_品質管理棟
CREATE TABLE measurements_building_3 PARTITION OF measurements
    FOR VALUES IN (3) PARTITION BY RANGE(timestamp);

-- インデックス_時系列クエリ
CREATE INDEX idx_measurements_timestamp_desc
    ON measurements (timestamp DESC);
-- インデックス_建屋・場所別クエリ
CREATE INDEX idx_measurements_location_timestamp
    ON measurements (location_id, timestamp DESC);
CREATE INDEX idx_measurements_location_type_timestamp 
    ON measurements (location_id, measure_type_id, timestamp);
