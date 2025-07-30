DO $$
DECLARE
    building_id INT;
    location_id INT;
    loop_measure_type_id INT;
    timestamp TIMESTAMPTZ;
    value DOUBLE PRECISION;
BEGIN
    FOR timestamp IN (
        SELECT generate_series(
            '2024-01-01 00:00:00'::timestamptz, 
            '2026-01-01 00:00:00'::timestamptz, 
            '1 hours'::interval
        )
    ) LOOP
        FOR building_id, location_id IN (
            SELECT l.building_id, l.location_id
            FROM locations l
        ) LOOP
            FOR loop_measure_type_id IN (
                SELECT m.measure_type_id
                FROM measure_types m
            ) LOOP
                SELECT
                    random() * (m.max_valid_value - m.min_valid_value) + m.min_valid_value
                INTO value
                FROM measure_types m
                WHERE m.measure_type_id = loop_measure_type_id;

                INSERT INTO measurements (
                    timestamp, building_id, location_id, measure_type_id, value
                )
                VALUES (
                    timestamp, building_id, location_id, loop_measure_type_id, value
                );
            END LOOP;
        END LOOP;
    END LOOP;
END $$;
