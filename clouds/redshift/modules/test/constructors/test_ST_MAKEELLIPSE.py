import os

from test_utils import run_query

here = os.path.dirname(__file__)


def test_makeellipse_success():
    results = run_query(
        """
        SELECT ST_ASGEOJSON(@@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, 3, -30, 'miles', 20)),
               ST_ASGEOJSON(@@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(13.9385,0.6643), 10, 2, 15, 'kilometers', 10)),
               ST_ASGEOJSON(@@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(53.9385,-10.6643), 8, 7, 100, 'miles', 15))
    """
    )

    with open(f'{here}/fixtures/st_makeellipse_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_makeenvelope_none_success():
    result = run_query(
        """
        SELECT @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                NULL, 5, 3, -30, 'miles', 80),
               @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), NULL, 3, -30, 'miles', 80),
               @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, NULL, -30, 'miles', 80),
               @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, 3, NULL, 'miles', 80),
               @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, 3, -30, NULL, 80),
               @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, 3, -30, 'miles', NULL)
    """
    )

    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None
    assert result[0][3] is None


def test_makeenvelope_default_args_success():
    result = run_query(
        """
        SELECT @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, 3, 0, 'kilometers', 64),
               @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, 3),
               @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, 3, 0),
               @@RS_SCHEMA@@.ST_MAKEELLIPSE(
                ST_POINT(-73.9385,40.6643), 5, 3, 0, 'kilometers')
    """
    )

    assert result[0][1] == result[0][0]
    assert result[0][2] == result[0][0]
    assert result[0][3] == result[0][0]
