from test_utils import run_query, redshift_connector


def test_st_centermean():
    result = run_query('SELECT @@RS_PREFIX@@transformations.ST_CENTERMEAN(geog)')
    assert result[0][0] == 