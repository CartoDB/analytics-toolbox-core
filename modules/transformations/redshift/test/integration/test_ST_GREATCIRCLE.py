from test_utils import run_query, redshift_connector


def test_st_greatcircle():
    result = run_query('SELECT @@RS_PREFIX@@transformations.ST_GREATCIRCLE(start_point, end_point, n_points)')
    assert result[0][0] == 