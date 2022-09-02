from python_utils.test_utils import run_query


def test_st_mlinefromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASGEOJSON(@@DB_SCHEMA@@.ST_MLINEFROMTEXT('MULTILINESTRING((1 1, 3 5), (-5 3, -8 -2))'));"
    result = run_query(query)
    assert (
        result[0][0]
        == '{"type":"MultiLineString","coordinates":[[[1,1,0.0],[3,5,0.0]],[[-5,3,0.0],[-8,-2,0.0]]]}'
    )
