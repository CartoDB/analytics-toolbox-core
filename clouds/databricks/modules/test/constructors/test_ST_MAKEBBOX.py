from python_utils.test_utils import run_query


def test_st_makebbox_success():
    query = 'SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_MAKEBBOX(-91.85548, 29.50603, -91.83820, 29.53073)) AS bbox;'
    result = run_query(query)
    assert (
        result[0][0]
        == 'POLYGON ((-91.85548 29.50603, -91.85548 29.53073, -91.8382 29.53073, -91.8382 29.50603, -91.85548 29.50603))'
    )
