from python_utils.run_query import run_query


def test_st_aslatlontext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASLATLONTEXT(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));"
    result = run_query(query)
    assert result[0][0] == '18°25\'39.000"N 77°54\'31.320"W'
