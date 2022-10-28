from python_utils.run_query import run_query


def test_st_geometryn_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_GEOMETRYN(@@DB_SCHEMA@@.ST_GEOMFROMWKT('GEOMETRYCOLLECTION(LINESTRING(1 1, 2 3), POINT(0 4), LINESTRING EMPTY)'), 2));"
    result = run_query(query)
    assert result[0][0] == 'POINT (0 4)'
