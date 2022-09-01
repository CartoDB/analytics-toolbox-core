import os
from test_utils.utils import run_query

def test_st_isgeomfield_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ISGEOMFIELD('LINESTRING(1 1, 2 3)');"
    result = run_query(query)
    assert result[0][0] == True