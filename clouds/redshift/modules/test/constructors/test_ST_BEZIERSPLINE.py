import os

from test_utils import run_query


here = os.path.dirname(__file__)


def test_bezierspline_success():
    with open(f'{here}/fixtures/st_bezierspline_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    results = run_query(
        f"""
        SELECT ST_ASGEOJSON(@@RS_SCHEMA@@.ST_BEZIERSPLINE(
                ST_GEOMFROMTEXT('{lines[0].rstrip()}'), 100, 0.85)),
               ST_ASGEOJSON(@@RS_SCHEMA@@.ST_BEZIERSPLINE(
                ST_GEOMFROMTEXT('{lines[1].rstrip()}'), 60, 0.85))
    """
    )

    with open(f'{here}/fixtures/st_bezierspline_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_bezierspline_none_success():
    with open(f'{here}/fixtures/st_bezierspline_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    result = run_query(
        f"""
        SELECT @@RS_SCHEMA@@.ST_BEZIERSPLINE(
                NULL, 10000, 0.9),
               @@RS_SCHEMA@@.ST_BEZIERSPLINE(
                ST_GEOMFROMTEXT('{lines[2].rstrip()}'), NULL, 0.9),
               @@RS_SCHEMA@@.ST_BEZIERSPLINE(
                ST_GEOMFROMTEXT('{lines[2].rstrip()}'), 10000, NULL)
    """
    )

    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None


def test_bezierspline_default_args_success():
    with open(f'{here}/fixtures/st_bezierspline_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    result = run_query(
        f"""
        SELECT @@RS_SCHEMA@@.ST_BEZIERSPLINE(
                ST_GEOMFROMTEXT('{lines[2].rstrip()}'), 10000, 0.85),
               @@RS_SCHEMA@@.ST_BEZIERSPLINE(
                ST_GEOMFROMTEXT('{lines[2].rstrip()}')),
               @@RS_SCHEMA@@.ST_BEZIERSPLINE(
                ST_GEOMFROMTEXT('{lines[2].rstrip()}'), 10000)
    """
    )

    assert result[0][1] == result[0][0]
    assert result[0][2] == result[0][0]
