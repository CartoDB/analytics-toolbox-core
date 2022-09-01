import os
from python_utils.test_utils import run_query

def test_st_makeextent_success():
    query = "SELECT @@DB_SCHEMA@@.ST_MAKEEXTENT(0, 0, 1, 1)"
    result = run_query(query)
    assert result[0][0] == {"xmin": 0, "ymin": 0, "xmax": 1, "ymax": 1}