from python_utils.run_query import run_query


def test_st_casttopoint_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_CASTTOPOINT(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(75 29)')));"
    result = run_query(query)
    assert result[0][0] == 'POINT (75 29)'
