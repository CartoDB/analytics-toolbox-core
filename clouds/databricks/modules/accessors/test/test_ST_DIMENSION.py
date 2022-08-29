import os
from test_utils.utils import run_query

def test_st_dimension_success():
    query = "SELECT @@DB_SCHEMA@@.ST_DIMENSION(@@DB_SCHEMA@@.ST_GEOMFROMWKT(\"LINESTRING(0 0, 1 1, 2 1)\"));"
    result = run_query(query)
    assert result[0][0] == 1




