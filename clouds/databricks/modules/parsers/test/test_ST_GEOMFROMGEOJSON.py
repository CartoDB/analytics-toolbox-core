import os
from test_utils.utils import run_query

def test_st_geomfromgeojson_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_GEOMFROMGEOJSON('{\"type\":\"Point\",\"coordinates\":[-76.0913,18.4275,0.0]}'));"
    result = run_query(query)
    assert result[0][0] == "POINT (-76.0913 18.4275)"