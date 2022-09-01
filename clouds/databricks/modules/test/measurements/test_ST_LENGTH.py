import os
from python_utils.test_utils import run_query

def test_st_length_success():
    query = "SELECT @@DB_SCHEMA@@.ST_LENGTH(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING(0 0, 0 3, 5 3)'));"
    result = run_query(query)
    assert result[0][0] == 8