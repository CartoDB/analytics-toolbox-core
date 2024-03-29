from python_utils.run_query import run_query


def test_st_linefromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASGEOJSON(@@DB_SCHEMA@@.ST_LINEFROMTEXT('LINESTRING(0 0, 0 3, 5 3)'));"
    result = run_query(query)
    assert (
        result[0][0]
        == '{"type":"LineString","coordinates":[[0.0,0.0],[0.0,3],[5,3]]}'
    )
