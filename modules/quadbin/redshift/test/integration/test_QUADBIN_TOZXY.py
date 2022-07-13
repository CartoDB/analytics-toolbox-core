from test_utils import run_query


def test_quadbin_tozxy():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_TOZXY(
                5209574053332910079) AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == '{"z":4,"x":9,"y":8}'
