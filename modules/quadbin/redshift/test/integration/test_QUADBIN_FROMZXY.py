from test_utils import run_query


def test_quadbin_fromzxy():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_FROMZXY(
                4,
                9,
                8) AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209574053332910079
