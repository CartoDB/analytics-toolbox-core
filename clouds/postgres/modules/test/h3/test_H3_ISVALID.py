from test_utils import run_query


def test_h3_isvalid():
    """Computes isvalid for h3."""
    result = run_query(
        """
            WITH ids AS
            (
                -- Invalid parameters
                SELECT 1 AS id, NULL as hid UNION ALL
                SELECT 2 AS id, 'ff283473fffffff' as hid UNION ALL

                -- Valid parameters
                SELECT 3 AS id, '85283473fffffff' as hid UNION ALL
                SELECT 4 AS id, '8075fffffffffff' as hid
            )
            SELECT
                id,
                @@PG_SCHEMA@@.H3_ISVALID(hid) as valid
            FROM ids
            ORDER BY id ASC
        """
    )
    assert len(result) == 4
    assert result[0][1] == False
    assert result[1][1] == False
    assert result[2][1] == True
    assert result[3][1] == True
