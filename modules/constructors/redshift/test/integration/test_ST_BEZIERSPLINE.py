from test_utils import run_query


def test_bezierspline_success():
    fixture_file = open('./test/integration/st_bezierspline_fixtures/in/wkts.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    results = run_query(
        f"""SELECT @@RS_PREFIX@@carto.ST_BEZIERSPLINE(
            ST_GeomFromText('{lines[0].rstrip()}'), 100, 0.85),
        @@RS_PREFIX@@carto.ST_BEZIERSPLINE(
            ST_GeomFromText('{lines[1].rstrip()}'), 60, 0.85)"""
    )

    fixture_file = open(
        './test/integration/st_bezierspline_fixtures/out/geojsons.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_bezierspline_none_success():
    fixture_file = open('./test/integration/st_bezierspline_fixtures/in/wkts.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    result = run_query(
        f"""SELECT @@RS_PREFIX@@carto.ST_BEZIERSPLINE(
                NULL, 10000, 0.9),
            @@RS_PREFIX@@carto.ST_BEZIERSPLINE(
                ST_GeomFromText('{lines[2].rstrip()}'), NULL, 0.9),
            @@RS_PREFIX@@carto.ST_BEZIERSPLINE(
                ST_GeomFromText('{lines[2].rstrip()}'), 10000, NULL)"""
    )

    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None


def test_bezierspline_default_args_success():
    fixture_file = open('./test/integration/st_bezierspline_fixtures/in/wkts.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    result = run_query(
        f"""SELECT @@RS_PREFIX@@carto.ST_BEZIERSPLINE(
                ST_GeomFromText('{lines[2].rstrip()}'), 10000, 0.85),
            @@RS_PREFIX@@carto.ST_BEZIERSPLINE(
                ST_GeomFromText('{lines[2].rstrip()}')),
            @@RS_PREFIX@@carto.ST_BEZIERSPLINE(
                ST_GeomFromText('{lines[2].rstrip()}'), 10000)"""
    )

    assert result[0][1] == result[0][0]
    assert result[0][2] == result[0][0]
