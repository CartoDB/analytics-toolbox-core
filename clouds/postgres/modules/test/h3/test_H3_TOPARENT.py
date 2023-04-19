from test_utils import run_query


def test_h3_toparent_invalid_input():
    """Returns null with invalid data."""

    result = run_query(
        """
            WITH ids AS
            (
                -- Invalid parameters
                SELECT 1 AS id, NULL as hid UNION ALL
                SELECT 2 AS id, 'ff283473fffffff' as hid
            )
            SELECT
                id,
                @@PG_SCHEMA@@.H3_TOPARENT(hid, 1) as parent
            FROM ids
            ORDER BY id ASC
        """
    )
    assert len(result) == 2
    assert result[0][1] is None
    assert result[1][1] is None


def test_h3_toparent():
    """Returns the equivalent to the previous resolution level."""
    # From h3-js tests:
    # NB: This test will not work with every hexagon, it has to be a location
    # that does not fall in the margin of error between the 7 children and
    # the parent's true boundaries at every resolution
    result = run_query(
        """
            WITH resolutions AS
            (
                SELECT 1 as resolution
                UNION ALL SELECT 2
                UNION ALL SELECT 3
                UNION ALL SELECT 4
                UNION ALL SELECT 5
                UNION ALL SELECT 6
                UNION ALL SELECT 7
                UNION ALL SELECT 8
                UNION ALL SELECT 9
                UNION ALL SELECT 10
            )
            ,ids AS
            (
                SELECT
                    ST_POINT(-122.409290778685, 37.81331899988944) as point,
                    resolution
                FROM resolutions
            )
            SELECT
                *
            FROM ids
            WHERE
                @@PG_SCHEMA@@.H3_FROMGEOGPOINT(point, resolution) != @@PG_SCHEMA@@.H3_TOPARENT(@@PG_SCHEMA@@.H3_FROMGEOGPOINT(point, resolution + 1), resolution) OR
                @@PG_SCHEMA@@.H3_FROMGEOGPOINT(point, resolution) != @@PG_SCHEMA@@.H3_TOPARENT(@@PG_SCHEMA@@.H3_FROMGEOGPOINT(point, resolution + 2), resolution)
        """
    )
    assert len(result) == 0
