from python_utils.test_utils import run_query


def test_st_distance_success():
    query = 'SELECT @@DB_SCHEMA@@.ST_DISTANCE(@@DB_SCHEMA@@.ST_POINT(0, 0), @@DB_SCHEMA@@.ST_POINT(0, 5));'
    result = run_query(query)
    assert result[0][0] == 5
