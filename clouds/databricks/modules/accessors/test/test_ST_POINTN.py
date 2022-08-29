import os
from test_utils.utils import run_query

def test_st_pointn_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_POINTN(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING(1 1, 2 3, 4 4, 3 4)'), 3));"
    result = run_query(query)
    assert result[0][0] == "POINT (4 4)"