import os
from test_utils.utils import run_query

def test_st_isring_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ISRING(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING(1 1, 2 3, 4 3, 1 1)'));"
    result = run_query(query)
    assert result[0][0] == True