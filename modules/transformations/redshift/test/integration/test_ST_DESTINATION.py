from test_utils import run_query, get_cursor
import os


def test_destination_success():
    results = run_query(
        """SELECT ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(0, 0), 10, 90, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(-3.70325, 40.4167), 5, 45, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(-43.7625, -20), 150, -20, 'miles'))"""
    )

    assert str(results[0][0]) == 'POINT(0.0899320363725 0)'
    assert str(results[0][1]) == 'POINT(-3.6614678544 40.4484882583)'
    assert str(results[0][2]) == 'POINT(-44.542881219 -17.9582789435)'


def test_destination_none():
    results = run_query(
        """SELECT ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            NULL, 10, 90, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(-3.70325, 40.4167), NULL, 45, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(-43.7625, -20), 150, NULL, 'miles')),
        ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(-43.7625, -20), 150, -20, NULL))"""
    )

    assert results[0][0] is None
    assert results[0][1] is None
    assert results[0][2] is None
    assert results[0][3] is None


def test_destination_default():
    results = run_query(
        """SELECT ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(0, 0), 10, 90)),
        ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(0, 0), 10, 90, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            ST_MakePoint(0, 0), 10, 90, 'miles'))"""
    )

    assert str(results[0][0]) == 'POINT(0.0899320363725 0)'
    assert str(results[0][1]) == str(results[0][0])
    assert str(results[0][1]) != str(results[0][2])


def test_read_from_table_success():
    cursor = get_cursor()

    cursor.execute(
        """
        CREATE TEMP TABLE test_data AS
        SELECT ST_MakePoint(0, 0) AS geom, 10 AS distance, 90 AS bearing,
            'kilometers' AS units, 1 AS idx UNION ALL
        SELECT ST_MakePoint(-3.70325, 40.4167) AS geom, 5 AS distance, 45 AS bearing,
            'kilometers' AS units, 2 AS idx UNION ALL
        SELECT ST_MakePoint(-43.7625, -20) AS geom, 150 AS distance, -20 AS bearing,
            'miles' AS units, 3 AS idx
        """
    )

    cursor.execute(
        """
        SELECT ST_ASTEXT(@@RS_PREFIX@@carto.ST_DESTINATION(
            geom, distance, bearing, units))
        FROM test_data ORDER BY idx
        """.replace(
            '@@RS_PREFIX@@', os.environ['RS_SCHEMA_PREFIX']
        )
    )

    results = cursor.fetchall()

    assert str(results[0][0]) == 'POINT(0.0899320363725 0)'
    assert str(results[1][0]) == 'POINT(-3.6614678544 40.4484882583)'
    assert str(results[2][0]) == 'POINT(-44.542881219 -17.9582789435)'
