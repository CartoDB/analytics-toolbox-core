from python_utils.test_utils import run_query


def test_st_geomreproject_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_POINT(3, 5) AS point, 
  @@DB_SCHEMA@@.ST_CRSFROMTEXT('+proj=merc +lat_ts=56.5 +ellps=GRS80') AS crsa,
  @@DB_SCHEMA@@.ST_CRSFROMTEXT('+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs') AS crsb
) SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_GEOMREPROJECT(point, crsa, crsb)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POINT (0.00003 0.00005)'