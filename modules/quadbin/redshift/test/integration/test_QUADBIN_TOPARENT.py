from test_utils import run_query


def test_quadbin_toparent():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_TOPARENT(
            5209574053332910079,
            3) AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5205105638077628415
