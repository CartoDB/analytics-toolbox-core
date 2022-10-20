from python_utils.run_query import run_query


def test_st_casttopolygon_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_CASTTOPOLYGON(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POLYGON((75 29, 77 29, 77 27, 75 29))')));"
    result = run_query(query)
    assert result[0][0] == 'POLYGON ((75 29, 77 29, 77 27, 75 29))'
