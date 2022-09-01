import os
from python_utils.test_utils import run_query

def test_st_mpolyfromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASGEOJSON(@@DB_SCHEMA@@.ST_MPOLYFROMTEXT('MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)),((15 5, 40 10, 10 20, 5 10, 15 5)))'));"
    result = run_query(query)
    assert result[0][0] == '{"type":"MultiPolygon","coordinates":[[[[30,20,0.0],[45,40,0.0],[10,40,0.0],[30,20,0.0]]],[[[15,5,0.0],[40,10,0.0],[10,20,0.0],[5,10,0.0],[15,5,0.0]]]]}'