from python_utils.test_utils import run_query


def test_st_isclosed_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ISCLOSED(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING(1 1, 2 3, 4 3, 1 1)'));"
    result = run_query(query)
    assert result[0][0] is True