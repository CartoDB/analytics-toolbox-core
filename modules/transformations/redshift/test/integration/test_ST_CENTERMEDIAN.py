from test_utils import run_query, redshift_connector


def test_st_centermedian():
    result = run_query('SELECT @@RS_PREFIX@@transformations.ST_CENTERMEDIAN(geog)')
    assert result[0][0] == result[0][0]
