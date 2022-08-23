import os
from test_utils.utils import run_query

def test_st_iscollection_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ISCOLLECTION(@@DB_SCHEMA@@.ST_GEOMFROMWKT('GEOMETRYCOLLECTION(LINESTRING(1 1, 2 3), POINT(0 4)), LINESTRING EMPTY'));"
    result = run_query(query)
    assert result[0][0] == True