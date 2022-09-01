import os
from python_utils.test_utils import run_query

def test_st_distancesphere_success():
    query = "SELECT @@DB_SCHEMA@@.ST_DISTANCESPHERE(@@DB_SCHEMA@@.ST_POINT(0, 0), @@DB_SCHEMA@@.ST_POINT(0, 5)) / 1000;"
    result = run_query(query)
    assert result[0][0] == 555.9753986718438