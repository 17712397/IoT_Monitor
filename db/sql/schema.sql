-- 建屋
DROP TABLE IF EXISTS buildings CASCADE;
CREATE TABLE buildings (
    building_id SERIAL PRIMARY KEY,
    building_name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 測定箇所
DROP TABLE IF EXISTS locations CASCADE;
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    building_id INT NOT NULL,
    location_name TEXT NOT NULL,
    floor_number INT,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_building FOREIGN KEY (building_id) REFERENCES buildings(building_id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (building_id, location_name, floor_number)
);

-- 測定種
DROP TABLE IF EXISTS measure_types CASCADE;
CREATE TABLE measure_types (
    measure_type_id SERIAL PRIMARY KEY,
    measure_type_name TEXT NOT NULL,
    unit VARCHAR(5) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- タグデータ
DROP TABLE IF EXISTS tags CASCADE;
CREATE TABLE tags (
    tag_id SERIAL PRIMARY KEY,
    building_id INT NOT NULL,
    location_id INT NOT NULL,
    measure_type_id INT NOT NULL,
    tag_code VARCHAR(10) NOT NULL UNIQUE,
    min_value DECIMAL(10, 3),
    max_value DECIMAL(10, 3),
    CONSTRAINT fk_building FOREIGN KEY (building_id) REFERENCES buildings(building_id),
    CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_measure_type FOREIGN KEY (measure_type_id) REFERENCES measure_types(measure_type_id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 測定データ
DROP TABLE IF EXISTS measurements CASCADE;
CREATE TABLE measurements (
    timestamp TIMESTAMPTZ NOT NULL,
    tag_id INT NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (timestamp, tag_id)
) PARTITION BY RANGE (timestamp);
