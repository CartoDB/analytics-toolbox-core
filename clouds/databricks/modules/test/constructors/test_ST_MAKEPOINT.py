from python_utils.run_query import run_query


def test_st_makepoint_success():
    query = 'SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_MAKEPOINT(-91.85548, 29.50603));'
    result = run_query(query)
    assert result[0][0] == 'POINT (-91.85548 29.50603)'
