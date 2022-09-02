from python_utils.test_utils import run_query


def test_st_coorddim_success():
    query = 'SELECT @@DB_SCHEMA@@.ST_COORDDIM(@@DB_SCHEMA@@.ST_MAKEPOINTM(1, 2, 3));'
    result = run_query(query)
    assert result[0][0] == 3
