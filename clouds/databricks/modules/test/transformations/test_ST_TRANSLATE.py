from python_utils.test_utils import run_query


def test_st_translate_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_POINT(0, 0) AS point
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_TRANSLATE(point, 1, 2)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POINT (1 2)'
