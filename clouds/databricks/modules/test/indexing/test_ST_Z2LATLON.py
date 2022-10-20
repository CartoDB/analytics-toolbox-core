from python_utils.run_query import run_query


def test_st_z2latlon_success():
    query = "SELECT @@DB_SCHEMA@@.ST_Z2LATLON(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING (0 0, 1 2)'))"
    result = run_query(query)
    assert result[0][0] == {'min': 864691128455135232, 'max': 864847779880401216}
