CREATE OR REPLACE VIEW vw_measurements_with_names_specific_id_1 AS
SELECT 
    m.timestamp,
    m.value,
    b.building_name,
    l.location_name
FROM 
    measurements m
JOIN 
    buildings b ON m.building_id = b.building_id
JOIN 
    locations l ON m.location_id = l.location_id
WHERE 
    m.building_id = 1 AND 
    m.measure_type_id = 1;

CREATE OR REPLACE VIEW vw_measurements_with_names_specific_id_2 AS
SELECT 
    m.timestamp,
    m.value,
    b.building_name,
    l.location_name
FROM 
    measurements m
JOIN 
    buildings b ON m.building_id = b.building_id
JOIN 
    locations l ON m.location_id = l.location_id
WHERE 
    m.building_id = 2 AND 
    m.measure_type_id = 2;

CREATE OR REPLACE VIEW vw_measurements_with_names_specific_id_3 AS
SELECT 
    m.timestamp,
    m.value,
    b.building_name,
    l.location_name
FROM 
    measurements m
JOIN 
    buildings b ON m.building_id = b.building_id
JOIN 
    locations l ON m.location_id = l.location_id
WHERE 
    m.building_id = 3 AND 
    m.measure_type_id = 3;
