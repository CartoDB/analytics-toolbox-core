from python_utils.run_query import run_query


def test_st_isvalid_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ISVALID(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POLYGON((0 0, 1 1, 1 2, 1 1, 0 0))'));"
    result = run_query(query)
    assert result[0][0] is False
