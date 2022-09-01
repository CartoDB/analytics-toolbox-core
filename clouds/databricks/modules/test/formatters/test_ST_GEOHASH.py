import os
from python_utils.test_utils import run_query

def test_st_geohash_success():
    query = "SELECT @@DB_SCHEMA@@.ST_GEOHASH(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8);"
    result = run_query(query)
    assert result[0][0] == "d4"