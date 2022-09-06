from python_utils.test_utils import run_query

def test_st_coorddim3_success():
    query = "SELECT @@DB_SCHEMA@@.ST_COORDDIM(@@DB_SCHEMA@@.ST_MAKEPOINTM(1, 2, 3));"
    result = run_query(query)
    assert result[0][0] == 3

def test_st_coorddim2_success():
    query = "SELECT @@DB_SCHEMA@@.ST_COORDDIM(@@DB_SCHEMA@@.ST_MAKEPOINT(1, 2));"
    result = run_query(query)
    assert result[0][0] == 2




