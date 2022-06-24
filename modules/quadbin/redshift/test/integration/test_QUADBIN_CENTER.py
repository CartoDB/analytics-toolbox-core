from test_utils import run_query


def test_quadbin_center():
    result = run_query(
        """SELECT ST_ASTEXT(
            @@RS_PREFIX@@carto.QUADBIN_CENTER(
                5209574053332910079)) AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 'POINT(33.75 -10.9715227667)'
