from python_utils.test_utils import run_query


def test_st_pointfromgeohash_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_ASGEOHASH(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8) AS geohash
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_POINTFROMGEOHASH(geohash, 5)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POINT (-67.5 22.5)'
