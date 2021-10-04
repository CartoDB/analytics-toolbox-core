from test_utils import run_query


def test_center_mean_success():
    fixture_file = open('./test/integration/center_fixtures/in/wkts.txt', 'r')
    points = fixture_file.readlines()
    fixture_file.close()

    results = run_query(
        f"""SELECT ST_ASTEXT(@@RS_PREFIX@@transformations.ST_CENTERMEAN(
            ST_GeomFromText('{points[0].rstrip()}'))),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_CENTERMEAN(
            ST_GeomFromText('{points[1].rstrip()}'))),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_CENTERMEAN(
            ST_GeomFromText('{points[2].rstrip()}'))),
        ST_ASTEXT(@@RS_PREFIX@@transformations.ST_CENTERMEAN(
            ST_GeomFromText('{points[3].rstrip()}')))"""
    )

    assert str(results[0][0]) == 'POINT(4.841194 45.758071)'
    assert str(results[0][1]) == 'POINT(25 27.5)'
    assert str(results[0][2]) == 'POINT(-58.75 22.5)'
    assert str(results[0][3]) == 'POINT(-3.790912 37.781073)'


def test_center_mean_none():
    results = run_query(
        """SELECT @@RS_PREFIX@@transformations.ST_CENTERMEAN(
            ST_GeomFromText(NULL))"""
    )

    assert results[0][0] is None
