import os
from python_utils.test_utils import run_query

def test_st_x_success():
    query = "SELECT @@DB_SCHEMA@@.ST_X(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));"
    result = run_query(query)
    # The result is rounded because it adds small decimal numbers
    assert round(result[0][0], 5) == -76.09130
