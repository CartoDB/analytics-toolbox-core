from test_utils import run_query


def test_destination_success():
    results = run_query(
        """SELECT ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(0, 0), 10, 90, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(-3.70325, 40.4167), 5, 45, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(-43.7625, -20), 150, -20, 'miles'))"""
    )

    assert str(results[0][0]) == 'POINT(0.0899320363725 0)'
    assert str(results[0][1]) == 'POINT(-3.6614678544 40.4484882583)'
    assert str(results[0][2]) == 'POINT(-44.542881219 -17.9582789435)'


def test_destination_none():
    results = run_query(
        """SELECT ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            NULL, 10, 90, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(-3.70325, 40.4167), NULL, 45, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(-43.7625, -20), 150, NULL, 'miles')),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(-43.7625, -20), 150, -20, NULL))"""
    )

    assert results[0][0] is None
    assert results[0][1] is None
    assert results[0][2] is None
    assert results[0][3] is None


def test_destination_default():
    results = run_query(
        """SELECT ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(0, 0), 10, 90)),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(0, 0), 10, 90, 'kilometers')),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_DESTINATION(
            ST_MakePoint(0, 0), 10, 90, 'miles'))"""
    )

    assert str(results[0][0]) == 'POINT(0.0899320363725 0)'
    assert str(results[0][1]) == str(results[0][0])
    assert str(results[0][1]) != str(results[0][2])
