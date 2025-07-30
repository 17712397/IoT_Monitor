CREATE OR REPLACE VIEW vw_building_total_power AS
SELECT 
    b.building_name,
    SUM(m.value) AS total_power,
    CASE 
        WHEN m.building_id = 1 THEN 1
        WHEN m.building_id = 2 THEN 5
        WHEN m.building_id = 3 THEN 5
        ELSE NULL
    END AS x_axis,
    CASE 
        WHEN m.building_id = 1 THEN 10
        WHEN m.building_id = 2 THEN 10
        WHEN m.building_id = 3 THEN 8
        ELSE NULL
    END AS y_axis
FROM 
    measurements m
JOIN 
    buildings b ON m.building_id = b.building_id
WHERE 
    m.measure_type_id = 3
GROUP BY 
    b.building_name, m.building_id;
