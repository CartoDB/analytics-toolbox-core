from test_utils import run_query


def test_h3_fromgeogpoint():
    """Returns the proper index."""
    result = run_query(
        """
            WITH inputs AS
            (
                SELECT 1 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
                SELECT 2 AS id, ST_POINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
                SELECT 3 AS id, ST_POINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL

                -- null inputs
                SELECT 4 AS id, NULL AS geom, 5 as resolution UNION ALL
                SELECT 5 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, -1 as resolution UNION ALL
                SELECT 6 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 20 as resolution UNION ALL
                SELECT 7 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, NULL as resolution
            )
            SELECT @@PG_SCHEMA@@.H3_FROMGEOGPOINT(geom, resolution) as h3_id
            FROM inputs
            ORDER BY id ASC
        """  # noqa
    )
    assert len(result) == 7
    assert result[0][0] == '85283473fffffff'
    assert result[1][0] == '8547732ffffffff'
    assert result[2][0] == '8f2000000000000'
    assert result[3][0] is None
    assert result[4][0] is None
    assert result[5][0] is None
    assert result[6][0] is None


def test_h3_fromgeogpoint_non_points():
    """Returns null with non point geometries."""
    result = run_query(
        """
            WITH inputs AS
            (
                SELECT 1 AS id, ST_GEOMFROMTEXT('LINESTRING(0 0, 10 10)') as geom, 5 as resolution UNION ALL
                SELECT 2 AS id, ST_GEOMFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 5 as resolution UNION ALL
                SELECT 3 AS id, ST_GEOMFROMTEXT('MULTIPOINT(0 0, 0 10, 10 10, 10 0, 0 0)') as geom, 5 as resolution
            )
            SELECT @@PG_SCHEMA@@.H3_FROMGEOGPOINT(geom, resolution) as h3_id
            FROM inputs
            ORDER BY id ASC
        """  # noqa
    )
    assert len(result) == 3
    assert result[0][0] is None
    assert result[1][0] is None
    assert result[2][0] is None


def test_h3_fromgeopoint():
    """Returns the proper index."""
    result = run_query(
        """
            WITH inputs AS
            (
                SELECT 1 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
                SELECT 2 AS id, ST_POINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
                SELECT 3 AS id, ST_POINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL

                -- null inputs
                SELECT 4 AS id, NULL AS geom, 5 as resolution UNION ALL
                SELECT 5 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, -1 as resolution UNION ALL
                SELECT 6 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 20 as resolution UNION ALL
                SELECT 7 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, NULL as resolution
            )
            SELECT @@PG_SCHEMA@@.H3_FROMGEOPOINT(geom, resolution) as h3_id
            FROM inputs
            ORDER BY id ASC
        """  # noqa
    )
    assert len(result) == 7
    assert result[0][0] == '85283473fffffff'
    assert result[1][0] == '8547732ffffffff'
    assert result[2][0] == '8f2000000000000'
    assert result[3][0] is None
    assert result[4][0] is None
    assert result[5][0] is None
    assert result[6][0] is None
