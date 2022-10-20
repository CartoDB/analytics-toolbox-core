from python_utils.run_query import run_query


def test_st_area_success():
    query = 'SELECT @@DB_SCHEMA@@.ST_AREA(@@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 2, 2));'
    result = run_query(query)
    assert result[0][0] == 4
