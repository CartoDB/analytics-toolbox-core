import os
from python_utils.test_utils import run_query

def test_st_makepolygon_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_MAKEPOLYGON(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING(75 29,77 29,77 27, 75 29)')));"
    result = run_query(query)
    assert result[0][0] == "POLYGON ((75 29, 77 29, 77 27, 75 29))"