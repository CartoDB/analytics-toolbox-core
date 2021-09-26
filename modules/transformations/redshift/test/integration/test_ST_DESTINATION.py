from test_utils import run_query, redshift_connector


def test_st_destination():
    result = run_query('SELECT @@RS_PREFIX@@transformations.ST_DESTINATION(geog, distance, bearing, units)')
    assert result[0][0] == 