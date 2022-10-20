from python_utils.run_query import run_query


def test_st_mpointfromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASGEOJSON(@@DB_SCHEMA@@.ST_MPOINTFROMTEXT('MULTIPOINT (10 40, 40 30, 20 20, 30 10)'));"
    result = run_query(query)
    assert (
        result[0][0]
        == '{"type":"MultiPoint","coordinates":[[10,40],[40,30],[20,20],[30,10]]}'
    )
