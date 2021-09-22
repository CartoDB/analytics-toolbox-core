from test_utils import run_query, redshift_connector


def test_st_centroid():
    result = run_query('SELECT @@RS_PREFIX@@transformations.ST_CENTROID(geog)')
    assert result[0][0] == result[0][0]
