from python_utils.run_query import run_query


def test_st_isempty_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ISEMPTY(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING EMPTY'));"
    result = run_query(query)
    assert result[0][0] is True
