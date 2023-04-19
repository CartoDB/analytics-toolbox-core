from test_utils import run_query


def test_h3_distance_invalid_inputs():
    """Works as expected with invalid input."""
    result = run_query(
        """
            WITH ids AS
            (
                -- Invalid parameters
                SELECT 1 AS id, NULL as hid1, '85283473fffffff' AS hid2 UNION ALL
                SELECT 2 AS id, 'ff283473fffffff' as hid1, '85283473fffffff' AS hid2 UNION ALL
                SELECT 3 AS id, '85283473fffffff' as hid1, NULL AS hid2 UNION ALL
                SELECT 4 AS id, '85283473fffffff' as hid1, 'ff283473fffffff' AS hid2 UNION ALL

                -- Self
                SELECT 5 AS id, '8928308280fffff' as hid1, '8928308280fffff' as hid2
            )
            SELECT
                id,
                @@PG_SCHEMA@@.H3_DISTANCE(hid1, hid2) as distance
            FROM ids
            ORDER BY id ASC
        """  # noqa
    )
    assert len(result) == 5
    assert result[0][1] is None
    assert result[1][1] is None
    assert result[2][1] is None
    assert result[3][1] is None
    assert result[4][1] == 0


def test_h3_distance_valid_inputs():
    """Works as expected with valid input."""
    result = run_query(
        """
            WITH distances AS
            (
                SELECT 0 AS distance
                UNION ALL SELECT 1
                UNION ALL SELECT 2
                UNION ALL SELECT 3
                UNION ALL SELECT 4
            ),
            ids AS
            (
            SELECT
                distance,
                '8928308280fffff' as hid1,
                hid2
            FROM
                distances,
                UNNEST (@@PG_SCHEMA@@.H3_HEXRING('8928308280fffff', distance)) hid2
            )
            SELECT @@PG_SCHEMA@@.H3_DISTANCE(hid1, hid2) as calculated_distance, *
            FROM ids
            WHERE @@PG_SCHEMA@@.H3_DISTANCE(hid1, hid2) != distance
        """
    )
    assert len(result) == 0
