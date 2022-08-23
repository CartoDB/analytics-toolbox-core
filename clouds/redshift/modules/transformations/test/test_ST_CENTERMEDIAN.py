import os

from test_utils import run_query, get_cursor


here = os.path.dirname(__file__)


def test_centermedian_success():
    with open(f'{here}/fixtures/st_centermedian_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    results = run_query(
        f"""SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTERMEDIAN(
            ST_GeomFromText('{lines[0].rstrip()}'))),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTERMEDIAN(
            ST_GeomFromText('{lines[1].rstrip()}'))),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTERMEDIAN(
            ST_GeomFromText('{lines[2].rstrip()}'))),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTERMEDIAN(
            ST_GeomFromText('{lines[3].rstrip()}')))"""
    )

    assert str(results[0][0]) == 'POINT(4.82410599215 45.7653117302)'
    assert str(results[0][1]) == 'POINT(26.3841869726 19.0088147377)'
    assert str(results[0][2]) == 'POINT(-92.2112940392 33.5479292546)'
    assert str(results[0][3]) == 'POINT(-3.79058763366 37.781928957)'


def test_centermedian_none():
    results = run_query(
        """SELECT @@RS_SCHEMA@@.ST_CENTERMEDIAN(
            ST_GeomFromText(NULL))"""
    )

    assert results[0][0] is None


def test_centermedian_read_from_table_success():
    with open(f'{here}/fixtures/st_centermedian_in.txt', 'r') as fixture_file:
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
        SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_CENTERMEDIAN(geom))
        FROM test_data ORDER BY idx
        """.replace(
            '@@RS_SCHEMA@@', os.environ['RS_SCHEMA']
        )
    )

    results = cursor.fetchall()

    assert str(results[0][0]) == 'POINT(4.82410599215 45.7653117302)'
    assert str(results[1][0]) == 'POINT(26.3841869726 19.0088147377)'
    assert str(results[2][0]) == 'POINT(-92.2112940392 33.5479292546)'
