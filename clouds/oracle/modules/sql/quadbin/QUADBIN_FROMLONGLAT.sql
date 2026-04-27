----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Converts longitude/latitude/resolution to a quadbin index via
-- Web Mercator projection, then delegates to QUADBIN_FROMZXY.
--
-- Coordinates are interpreted as WGS84 (EPSG:4326) degrees. There is no
-- auto-transform from other CRSs in v1.0; callers must project beforehand.
--
-- Uses BINARY_DOUBLE (IEEE 754) for intermediate calculations to match
-- the floating-point behaviour of other platforms (Databricks DOUBLE, etc.).
--
-- Algorithm:
--   1. Validate resolution is in [0, 26]
--   2. Clamp latitude to [-89, 89]
--   3. Compute tile coordinates using Web Mercator projection
--   4. Wrap x on torus using BITAND (num_tiles is always a power of 2)
--   5. Delegate to QUADBIN_FROMZXY(z, x, y)

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT
(longitude NUMBER, latitude NUMBER, resolution NUMBER)
RETURN NUMBER
AS
    MIN_RESOLUTION CONSTANT NUMBER := 0;
    MAX_RESOLUTION CONSTANT NUMBER := 26;
    LAT_CLAMP_MIN  CONSTANT BINARY_DOUBLE := -89.0d;
    LAT_CLAMP_MAX  CONSTANT BINARY_DOUBLE := 89.0d;

    v_lon          BINARY_DOUBLE;
    v_num_tiles    BINARY_DOUBLE;
    v_pi           BINARY_DOUBLE;
    v_clamped_lat  BINARY_DOUBLE;
    v_sinlat       BINARY_DOUBLE;
    v_raw_x        NUMBER;
    v_x            NUMBER;
    v_y            NUMBER;
BEGIN
    IF longitude IS NULL OR latitude IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;

    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Invalid resolution: should be between '
                || MIN_RESOLUTION || ' and ' || MAX_RESOLUTION
        );
    END IF;

    v_lon := CAST(longitude AS BINARY_DOUBLE);
    v_num_tiles := POWER(2.0d, CAST(resolution AS BINARY_DOUBLE));
    v_pi := ACOS(-1.0d);
    v_clamped_lat := GREATEST(LAT_CLAMP_MIN,
                              LEAST(LAT_CLAMP_MAX,
                                    CAST(latitude AS BINARY_DOUBLE)));

    v_sinlat := SIN(v_clamped_lat * v_pi / 180.0d);

    -- Tile x: floor(num_tiles * (lon/360 + 0.5)), then wrap on torus
    v_raw_x := FLOOR(v_num_tiles * ((v_lon / 360.0d) + 0.5d));
    v_x := BITAND(v_raw_x, POWER(2, resolution) - 1);

    -- Tile y: floor(clamp(num_tiles * (0.5 - 0.25 * ln((1+sinlat)/(1-sinlat)) / pi)))
    v_y := FLOOR(
        CAST(
            GREATEST(
                0.0d,
                LEAST(
                    v_num_tiles - 1.0d,
                    v_num_tiles * (
                        0.5d - 0.25d
                        * LN((1.0d + v_sinlat) / (1.0d - v_sinlat))
                        / v_pi
                    )
                )
            )
        AS NUMBER)
    );

    RETURN @@ORA_SCHEMA@@.QUADBIN_FROMZXY(resolution, v_x, v_y);
END;
/
