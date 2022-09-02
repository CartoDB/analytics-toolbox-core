from python_utils.test_utils import run_query


def test_st_mpointfromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASGEOJSON(@@DB_SCHEMA@@.ST_MPOINTFROMTEXT('MULTIPOINT (10 40, 40 30, 20 20, 30 10)'));"
    result = run_query(query)
    assert (
        result[0][0]
        == '{"type":"MultiPoint","coordinates":[[10,40,0.0],[40,30,0.0],[20,20,0.0],[30,10,0.0]]}'
    )
