import os
from python_utils.test_utils import run_query

def test_st_isempty_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ISEMPTY(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING EMPTY'));"
    result = run_query(query)
    assert result[0][0] == True