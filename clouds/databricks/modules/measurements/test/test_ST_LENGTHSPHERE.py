import os
from test_utils.utils import run_query

def test_st_lengthsphere_success():
    query = "SELECT @@DB_SCHEMA@@.ST_LENGTHSPHERE(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING(0 0, 0 3, 5 3)')) / 1000;"
    result = run_query(query)
    assert result[0][0] == 888.7982099954688