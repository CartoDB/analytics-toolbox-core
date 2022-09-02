from python_utils.test_utils import run_query


def test_st_envelope_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_ENVELOPE(@@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING(1 1, 2 3)')));"
    result = run_query(query)
    assert result[0][0] == 'POLYGON ((1 1, 1 3, 2 3, 2 1, 1 1))'
