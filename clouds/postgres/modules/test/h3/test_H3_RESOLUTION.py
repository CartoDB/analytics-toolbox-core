from test_utils import run_query


def test_h3_resolution_invalid_input():
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
                @@PG_SCHEMA@@.H3_RESOLUTION(hid) as resolution
            FROM ids
            ORDER BY id ASC
        """
    )
    assert len(result) == 2
    assert result[0][1] is None
    assert result[1][1] is None


def test_h3_resolution():
    """Returns expected resolution for h3."""
    result = run_query(
        """
            WITH ids AS
            (
                SELECT 1 AS id, '85283473fffffff' as hid, 5 AS expected UNION ALL
                SELECT 2 AS id, '81623ffffffffff' as hid, 1 AS expected
            )
            SELECT
                *,
                @@PG_SCHEMA@@.H3_RESOLUTION(hid) as resolution
            FROM ids
            WHERE expected != @@PG_SCHEMA@@.H3_RESOLUTION(hid)
        """
    )
    assert len(result) == 0
