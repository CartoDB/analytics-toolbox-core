import os
from test_utils.utils import run_query

def test_st_geometryfromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASGEOJSON(@@DB_SCHEMA@@.ST_GEOMETRYFROMTEXT('POINT(-76.09130 18.42750)'));"
    result = run_query(query)
    assert result[0][0] == '{"type":"Point","coordinates":[-76.0913,18.4275,0.0]}'