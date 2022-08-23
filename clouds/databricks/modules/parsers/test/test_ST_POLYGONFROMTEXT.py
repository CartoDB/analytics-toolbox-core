import os
from test_utils.utils import run_query

def test_st_polygonfromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASGEOJSON(@@DB_SCHEMA@@.ST_POLYGONFROMTEXT('POLYGON((-73.98955 40.71278, -73.98958 40.71299, -73.98955 40.71278))'));"
    result = run_query(query)
    assert result[0][0] == '{"type":"Polygon","coordinates":[[[-73.98955,40.71278,0.0],[-73.98958,40.71299,0.0],[-73.98955,40.71278,0.0],[-73.98955,40.71278,0.0]]]}'