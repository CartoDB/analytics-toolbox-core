from test_utils import run_query


def test_h3_center():
    result = run_query(
        "SELECT ST_ASTEXT(@@RS_SCHEMA@@.H3_CENTER('85283473fffffff'))"
    )

    assert len(result[0]) == 1
    assert result[0][0] == 'POINT(-121.976375973 37.3457933754)'
