from python_utils.test_utils import run_query


def test_st_geomfromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASGEOJSON(@@DB_SCHEMA@@.ST_GEOMFROMTEXT('POINT(-76.09130 18.42750)'));"
    result = run_query(query)
    assert result[0][0] == '{"type":"Point","coordinates":[-76.0913,18.4275]}'
