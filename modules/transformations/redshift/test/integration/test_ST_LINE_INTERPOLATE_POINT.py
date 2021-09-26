from test_utils import run_query, redshift_connector


def test_st_line_interpolate_point():
    result = run_query('SELECT @@RS_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT(geog, distance, units)')
    assert result[0][0] == 