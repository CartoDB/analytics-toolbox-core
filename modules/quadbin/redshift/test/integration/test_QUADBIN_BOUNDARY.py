from test_utils import run_query


def test_quadbin_boundary():
    result = run_query(
        """SELECT ST_ASTEXT(
            @@RS_PREFIX@@carto.QUADBIN_BOUNDARY(
                5209574053332910079)) AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == (
        'POLYGON((22.5 -21.9430455334,22.5 0,'
        '45 0,45 -21.9430455334,22.5 -21.9430455334))'
    )
