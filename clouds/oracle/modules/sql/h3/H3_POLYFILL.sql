----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Private MLE binding to h3-js polyfill (CENTER mode for Polygon /
-- MultiPolygon inputs; non-polygon inputs are silently ignored, matching
-- the established SF/BQ pattern). Mode-aware filtering for intersects /
-- contains is done in PL/SQL via SDO_GEOM.RELATE.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.INTERNAL_H3_POLYFILL_JS
(geojson CLOB, resolution NUMBER)
RETURN CLOB
AS MLE MODULE @@ORA_SCHEMA@@.h3_module
SIGNATURE 'polyfill(string, number)';
/

-- Pipelined wrapper. Marshals SDO_GEOMETRY → GeoJSON, calls the JS
-- export, then pipes each cell. NULL inputs or any error inside h3-js
-- yield an empty pipeline.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_POLYFILL
(
    geom SDO_GEOMETRY, resolution NUMBER
)
RETURN @@ORA_SCHEMA@@.H3_INDEX_ARRAY PIPELINED
AS
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;

    v_geom    SDO_GEOMETRY;
    v_geojson CLOB;
    v_cells   CLOB;
BEGIN
    IF geom IS NULL OR resolution IS NULL THEN
        RETURN;
    END IF;
    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
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
    v_cells := @@ORA_SCHEMA@@.INTERNAL_H3_POLYFILL_JS(v_geojson, resolution);

    FOR rec IN (
        SELECT jt.cell AS h3
        FROM JSON_TABLE(
            v_cells, '$[*]'
            COLUMNS (cell VARCHAR2(16) PATH '$')
        ) jt
    ) LOOP
        PIPE ROW(rec.h3);
    END LOOP;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        RETURN;
END;
/
