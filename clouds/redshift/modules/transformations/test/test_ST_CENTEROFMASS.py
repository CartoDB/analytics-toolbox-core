import os

from test_utils import run_query, get_cursor


here = os.path.dirname(__file__)


def test_centerofmass_success():
    with open(f'{here}/fixtures/st_centerofmass_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    results = run_query(
        f"""SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTEROFMASS(
            ST_GeomFromText('{lines[0].rstrip()}'))),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTEROFMASS(
            ST_GeomFromText('{lines[1].rstrip()}'))),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTEROFMASS(
            ST_GeomFromText('{lines[2].rstrip()}'))),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTEROFMASS(
            ST_GeomFromText('{lines[3].rstrip()}')))"""
    )

    assert str(results[0][0]) == 'POINT(4.84072896514 45.7558120999)'
    assert str(results[0][1]) == 'POINT(25.4545454545 26.9696969697)'
    assert str(results[0][2]) == 'POINT(-50.197740113 19.1525423729)'
    assert str(results[0][3]) == 'POINT(-3.79060166354 37.7788081595)'


def test_centerofmass_none():
    results = run_query(
        """SELECT @@RS_SCHEMA@@.ST_CENTEROFMASS(
            ST_GeomFromText(NULL))"""
    )

    assert results[0][0] is None


def test_centerofmass_read_from_table_success():
    with open(f'{here}/fixtures/st_centerofmass_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    cursor = get_cursor()

    cursor.execute(
        f"""
        CREATE TEMP TABLE test_data AS
        SELECT ST_GEOMFROMTEXT('{lines[0].rstrip()}') AS geom, 1 AS idx UNION ALL
        SELECT ST_GEOMFROMTEXT('{lines[1].rstrip()}') AS geom, 2 AS idx UNION ALL
        SELECT ST_GEOMFROMTEXT('{lines[2].rstrip()}') AS geom, 3 AS idx
        """
    )

    cursor.execute(
        """
        SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTEROFMASS(geom))
        FROM test_data ORDER BY idx
        """.replace(
            '@@RS_SCHEMA@@', os.environ['RS_SCHEMA']
        )
    )

    results = cursor.fetchall()

    assert str(results[0][0]) == 'POINT(4.84072896514 45.7558120999)'
    assert str(results[1][0]) == 'POINT(25.4545454545 26.9696969697)'
    assert str(results[2][0]) == 'POINT(-50.197740113 19.1525423729)'
