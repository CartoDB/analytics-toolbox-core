from test_utils import run_query


def test_h3_center_invalid_input():
    """Returns null with invalid inputs."""
    result = run_query(
        """
            WITH ids AS
            (
                SELECT 1 AS id, NULL as hid UNION ALL
                SELECT 2 AS id, 'ff283473fffffff' as hid
            )
            SELECT
                id,
                @@PG_SCHEMA@@.H3_CENTER(hid) as bounds
            FROM ids
            ORDER BY id ASC
        """
    )
    assert len(result) == 2
    assert result[0][1] is None
    assert result[1][1] is None


def test_h3_center_null_expected():
    """Returns null if the geometry is the expected."""
    result = run_query(
        """
            WITH ids AS
            (
                SELECT 1 AS id, @@PG_SCHEMA@@.H3_CENTER('85283473fffffff') as bounds, ST_GEOMFROMTEXT('SRID=4326;POINT(-121.9763759725512 37.34579337536848)') AS expected UNION ALL
                SELECT 2 AS id, @@PG_SCHEMA@@.H3_CENTER('81623ffffffffff') as bounds, ST_GEOMFROMTEXT('SRID=4326;POINT (58.157705839572586 10.447345187511033)') AS expected
            )
            SELECT
                *
            FROM ids
            WHERE NOT ST_EQUALS(expected, bounds) or bounds is null
        """  # noqa
    )
    assert len(result) == 0
