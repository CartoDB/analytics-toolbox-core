from python_utils.test_utils import run_query


def test_st_bufferpoint_success():
    query = 'SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_BUFFERPOINT(@@DB_SCHEMA@@.ST_POINT(0, 0), 1));;'
    result = run_query(query)
    assert result[0][0].startswith(
        'POLYGON ((0.000009 0, 0.000009 0.0000006, 0.0000089 0.0000011, 0.0000088 0.0000017,'
    )
