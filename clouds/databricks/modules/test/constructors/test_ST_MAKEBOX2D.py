from python_utils.run_query import run_query


def test_st_makebox2d_success():
    query = 'SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_MAKEBOX2D(@@DB_SCHEMA@@.ST_MAKEPOINT(-91.85548, 29.50603), @@DB_SCHEMA@@.ST_MAKEPOINT(-91.83820, 29.53073))) AS bbox;'
    result = run_query(query)
    assert (
        result[0][0]
        == 'POLYGON ((-91.85548 29.50603, -91.85548 29.53073, -91.8382 29.53073, -91.8382 29.50603, -91.85548 29.50603))'
    )
