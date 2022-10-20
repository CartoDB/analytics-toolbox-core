from python_utils.run_query import run_query


def test_st_y_success():
    query = 'SELECT @@DB_SCHEMA@@.ST_Y(@@DB_SCHEMA@@.ST_POINT(-76.09130, 18.42750));'
    result = run_query(query)
    assert round(result[0][0], 4) == 18.4275
