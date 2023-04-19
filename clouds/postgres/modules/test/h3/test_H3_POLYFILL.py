from test_utils import run_query


def test_h3_polyfill():
    """Computes polyfill for h3."""
    result = run_query(
        """
            WITH inputs AS
            (
                SELECT 1 AS id, ST_GEOMFROMTEXT('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))') as geom, 9 as resolution UNION ALL
                SELECT 2 AS id, ST_GEOMFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 2 as resolution UNION ALL
                SELECT 3 AS id, ST_GEOMFROMTEXT('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))') as geom, 2 as resolution UNION ALL
                -- 4 is a multipolygon containing geom ids 2, 3
                SELECT 4 AS id, ST_GEOMFROMTEXT('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))') as geom, 2 as resolution UNION ALL
                SELECT 5 AS id, ST_GEOMFROMTEXT('GEOMETRYCOLLECTION(POLYGON((20 20, 20 30, 30 30, 30 20, 20 20)), POINT(0 10), LINESTRING(0 0, 1 1),MULTIPOLYGON(((-50 -50, -50 -40, -40 -40, -40 -50, -50 -50)), ((50 50, 50 40, 40 40, 40 50, 50 50))))') as geom, 2 as resolution UNION ALL

                SELECT 6 AS id, ST_GEOMFROMTEXT('POLYGON((0 0, 0 .0001, .0001 .0001, .0001 0, 0 0))') as geom, 15 as resolution UNION ALL
                SELECT 7 AS id, ST_GEOMFROMTEXT('POLYGON((0 0, 0 50, 50 50, 50 0, 0 0))') as geom, 0 as resolution UNION ALL

                -- NULL and empty
                SELECT 8 AS id, NULL as geom, 2 as resolution UNION ALL
                SELECT 9 AS id, ST_GEOMFROMTEXT('POLYGON EMPTY') as geom, 2 as resolution UNION ALL

                -- Invalid resolution
                SELECT 10 AS id, ST_GEOMFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
                SELECT 11 AS id, ST_GEOMFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 16 as resolution UNION ALL
                SELECT 12 AS id, ST_GEOMFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution UNION ALL

                -- Other supported types
                SELECT 13 AS id, ST_GEOMFROMTEXT('POINT(0 0)') as geom, 15 as resolution UNION ALL
                SELECT 14 AS id, ST_GEOMFROMTEXT('MULTIPOINT(0 0, 1 1)') as geom, 15 as resolution UNION ALL
                SELECT 15 AS id, ST_GEOMFROMTEXT('LINESTRING(0 0, 1 1)') as geom, 3 as resolution UNION ALL
                SELECT 16 AS id, ST_GEOMFROMTEXT('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))') as geom, 3 as resolution UNION ALL
                -- 15 is a geometry collection containing only not supported types
                SELECT 17 AS id, ST_GEOMFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') as geom, 1 as resolution UNION ALL
                -- Polygon larger than 180 degrees
                SELECT 18 AS id, ST_GEOMFROMGEOJSON('{"type":"Polygon","coordinates":[[[-161.44993041898587,-3.77971025880735],[129.99811811657568,-3.77971025880735],[129.99811811657568,63.46915831771922],[-161.44993041898587,63.46915831771922],[-161.44993041898587,-3.77971025880735]]]}') as geom, 3 as resolution
            )
            SELECT
            ARRAY_LENGTH(@@PG_SCHEMA@@.H3_POLYFILL(geom, resolution), 1) AS id_count
            FROM inputs
            ORDER BY id ASC
        """  # noqa
    )
    assert len(result) == 18
    assert result[0][0] == 1253
    assert result[1][0] == 18
    assert result[2][0] == 12
    assert result[3][0] == 30
    assert result[4][0] == 34
    assert result[5][0] == 182
    assert result[6][0] == 6
    assert result[7][0] is None
    assert result[8][0] is None
    assert result[9][0] is None
    assert result[10][0] is None
    assert result[11][0] is None
    assert result[12][0] == 1
    assert result[13][0] == 1
    assert result[14][0] is None
    assert result[15][0] is None
    assert result[16][0] is None
    assert result[17][0] == 16110


def test_h3_polyfill_points():
    """Returns the expected values."""
    result = run_query(
        """
            WITH points AS
            (
                SELECT ST_POINT(0, 0) AS geom, 7 AS resolution UNION ALL
                SELECT ST_POINT(-122.4089866999972145, 37.813318999983238) AS geom, 7 AS resolution UNION ALL
                SELECT ST_POINT(-122.0553238, 37.3615593) AS geom, 7 AS resolution
            ),
            cells AS
            (
                SELECT
                    resolution,
                    @@PG_SCHEMA@@.H3_FROMGEOGPOINT(geom, resolution) AS h3_id,
                    @@PG_SCHEMA@@.H3_BOUNDARY(@@PG_SCHEMA@@.H3_FROMGEOGPOINT(geom, resolution)) AS boundary
                FROM points
            ),
            polyfill AS
            (
                SELECT
                    *,
                    @@PG_SCHEMA@@.H3_POLYFILL(boundary, resolution) p
                FROM cells
            )
            SELECT
                *
            FROM  polyfill
            WHERE
                ARRAY_LENGTH(p, 1) != 1 OR
                p[0] != h3_id
        """  # noqa
    )
    assert len(result) == 0
