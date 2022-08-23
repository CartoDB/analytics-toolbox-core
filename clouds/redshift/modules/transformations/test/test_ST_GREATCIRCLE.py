import os

from test_utils import run_query, get_cursor


here = os.path.dirname(__file__)


def test_greatcircle_success():
    results = run_query(
        """SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(0,0), ST_MakePoint(0,10), 11)),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(-1.70325, 1.4167), ST_MakePoint(1.70325, -1.4167), 5)),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(5, 5), ST_MakePoint(-5,-5), 9)),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(-86.90549445521091, 40.42831126209373),
            ST_MakePoint(-3.79289595262835, 37.776008883554354), 15))"""
    )

    with open(f'{here}/fixtures/st_greatcircle_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_greatcircle_none():
    results = run_query(
        """SELECT @@RS_SCHEMA@@.ST_GREATCIRCLE(
            NULL, ST_MakePoint(-5,-5), 5),
        @@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(-5,-5), NULL, 5),
        @@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(-5,-5), ST_MakePoint(5,5), NULL) """
    )

    assert results[0][0] is None
    assert results[0][1] is None
    assert results[0][2] is None


def test_greatcircle_default():
    results = run_query(
        """SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(-1.70325, 1.4167), ST_MakePoint(1.70325, -1.4167))),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(-1.70325, 1.4167), ST_MakePoint(1.70325, -1.4167), 100)),
        ST_ASTEXT(@@RS_SCHEMA@@.ST_GREATCIRCLE(
            ST_MakePoint(-1.70325, 1.4167), ST_MakePoint(1.70325, -1.4167), 10))"""
    )

    with open(f'{here}/fixtures/st_greatcircle_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    assert str(results[0][0]) == lines[4].rstrip()
    assert str(results[0][0]) == str(results[0][1])
    assert str(results[0][0]) != str(results[0][2])


def test_greatcircle_read_from_table_success():
    cursor = get_cursor()

    cursor.execute(
        """
        CREATE TEMP TABLE test_data AS
        SELECT ST_MakePoint(0,0) AS start_point,
            ST_MakePoint(0,10) AS end_point,
            11 AS npoints, 1 AS idx UNION ALL
        SELECT ST_MakePoint(-1.70325, 1.4167) AS start_point,
            ST_MakePoint(1.70325, -1.4167) AS end_point,
            5 AS npoints, 2 AS idx UNION ALL
        SELECT ST_MakePoint(5, 5) AS start_points,
            ST_MakePoint(-5,-5) AS end_point,
            9 AS npoints, 3 AS idx
        """
    )

    cursor.execute(
        """
        SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_GREATCIRCLE(
            start_point, end_point, npoints))
        FROM test_data ORDER BY idx
        """.replace(
            '@@RS_SCHEMA@@', os.environ['RS_SCHEMA']
        )
    )

    results = cursor.fetchall()

    with open(f'{here}/fixtures/st_greatcircle_table_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
