from python_utils.test_utils import run_query


def test_st_box2dfromgeohash_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_GEOHASH(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8) AS geohash
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_BOX2DFROMGEOHASH(geohash, 5)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POLYGON ((-90 0, -90 45, -45 45, -45 0, -90 0))'
