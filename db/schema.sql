-- 建屋
DROP TABLE IF EXISTS buildings CASCADE;
CREATE TABLE buildings (
    building_id SERIAL PRIMARY KEY,
    building_name TEXT NOT NULL UNIQUE
);

-- 測定箇所
DROP TABLE IF EXISTS locations CASCADE;
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    building_id INT NOT NULL REFERENCES buildings(building_id) ON DELETE CASCADE,
    location_name TEXT NOT NULL,
    UNIQUE (building_id, location_name)
);

-- 測定種
DROP TABLE IF EXISTS measure_types CASCADE;
CREATE TABLE measure_types (
    measure_type_id SERIAL PRIMARY KEY,
    measure_type TEXT NOT NULL UNIQUE
);

-- 測定データ
DROP TABLE IF EXISTS measurements CASCADE;
CREATE TABLE measurements (
    timestamp TIMESTAMP NOT NULL,
    building_id INT NOT NULL REFERENCES buildings(building_id) ON DELETE CASCADE,
    location_id INT NOT NULL REFERENCES locations(location_id) ON DELETE CASCADE,
    measure_type_id INT NOT NULL REFERENCES measure_types(measure_type_id) ON DELETE CASCADE,
    value DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (timestamp, building_id, location_id, measure_type_id)
) PARTITION BY LIST (building_id);

-- 測定データ_アーカイブ
DROP TABLE IF EXISTS measurements_archive CASCADE;
CREATE TABLE measurements_archive (
    timestamp TIMESTAMP NOT NULL,
    building_id INT NOT NULL,
    location_id INT NOT NULL,
    measure_type_id INT NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (timestamp, building_id, location_id, measure_type_id)
);

-- 建屋パーティション_配送センター
CREATE TABLE measurements_building_1 PARTITION OF measurements
FOR VALUES IN (1);

-- 建屋パーティション_研究棟
CREATE TABLE measurements_building_2 PARTITION OF measurements
FOR VALUES IN (2);

-- 建屋パーティション_品質管理棟
CREATE TABLE measurements_building_3 PARTITION OF measurements
FOR VALUES IN (3);

-- 複合インデックス_
CREATE INDEX idx_measurements_location_type_timestamp 
ON measurements (location_id, measure_type_id, timestamp);
