----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Private MLE binding to the JavaScript `polyfill` export. Returns a
-- JSON array of quadbin index strings (full 64-bit precision preserved
-- by string serialization).
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.INTERNAL_QUADBIN_POLYFILL_JS
(geojson VARCHAR2, resolution NUMBER)
RETURN CLOB
AS MLE MODULE @@ORA_SCHEMA@@.quadbin_module
SIGNATURE 'polyfill(string, number)';
/

-- Returns the set of quadbin tiles whose boundary intersects the input
-- geometry at the given resolution, as a pipelined QUADBIN_INDEX_ARRAY.
-- Consume via:
--   SELECT COLUMN_VALUE FROM TABLE(QUADBIN_POLYFILL(geom, 17));
--
-- The PL/SQL wrapper handles type marshaling:
--   1. SDO_GEOMETRY → GeoJSON string (SRID normalised to 4326 for WGS84)
--   2. Call MLE: returns a JSON array of quadbin strings
--   3. Parse JSON and pipe each cell as a NUMBER
--
-- NULL-on-invalid: returns an empty pipeline for NULL inputs or
-- out-of-range resolution.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_POLYFILL
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    v_geom    SDO_GEOMETRY;
    v_geojson CLOB;
    v_cells   CLOB;
BEGIN
    IF geom IS NULL OR resolution IS NULL THEN
        RETURN;
    END IF;
    IF resolution < 0 OR resolution > 26 THEN
        RETURN;
    END IF;

    -- Ensure SRID 4326 so TO_GEOJSON emits WGS84 lon/lat.
    IF geom.SDO_SRID IS NULL OR geom.SDO_SRID != 4326 THEN
        v_geom := geom;
        v_geom.SDO_SRID := 4326;
    ELSE
        v_geom := geom;
    END IF;

    v_geojson := SDO_UTIL.TO_GEOJSON(v_geom);
    v_cells := @@ORA_SCHEMA@@.INTERNAL_QUADBIN_POLYFILL_JS(v_geojson, resolution);

    -- Quadbin indices arrive as quoted strings (full 64-bit precision).
    -- Unpack with JSON_TABLE and parse each as NUMBER.
    FOR rec IN (
        SELECT TO_NUMBER(jt.cell) AS qb
        FROM JSON_TABLE(
            v_cells, '$[*]'
            COLUMNS (cell VARCHAR2(30) PATH '$')
        ) jt
    ) LOOP
        PIPE ROW(rec.qb);
    END LOOP;

    RETURN;
END;
/
