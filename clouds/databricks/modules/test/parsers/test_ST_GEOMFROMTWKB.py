from python_utils.run_query import run_query


def test_st_geomfromtwkb_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_ASTWKB(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)')) AS twkb
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_GEOMFROMTWKB(twkb)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POINT (-76.0913 18.4275)'
