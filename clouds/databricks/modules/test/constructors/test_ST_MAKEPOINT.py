import os
from test_utils.utils import run_query

def test_st_makepoint_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_MAKEPOINT(-91.8554869, 29.5060349));"
    result = run_query(query)
    assert result[0][0] == "POINT (-91.8554869 29.5060349)"