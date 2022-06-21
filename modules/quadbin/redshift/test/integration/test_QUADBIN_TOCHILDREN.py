from test_utils import run_query, redshift_connector
import pytest


def test_tochildren_success():
    results = run_query(
        """WITH tileContext AS(
            SELECT 0 AS zoom, 0 AS tileX, 0 AS tileY UNION ALL
            SELECT 1, 1, 1 UNION ALL
            SELECT 2, 2, 3 UNION ALL
            SELECT 3, 4, 5 UNION ALL
            SELECT 4, 6, 8 UNION ALL
            SELECT 5, 10, 20 UNION ALL
            SELECT 6, 40, 50 UNION ALL
            SELECT 7, 80, 90 UNION ALL
            SELECT 8, 160, 170 UNION ALL
            SELECT 9, 320, 320 UNION ALL
            SELECT 10, 640, 160 UNION ALL
            SELECT 11, 1280, 640 UNION ALL
            SELECT 12, 2560, 1280 UNION ALL
            SELECT 13, 5120, 160 UNION ALL
            SELECT 14, 10240, 80 UNION ALL
            SELECT 15, 20480, 40 UNION ALL
            SELECT 16, 40960, 80 UNION ALL
            SELECT 17, 81920, 160 UNION ALL
            SELECT 18, 163840, 320 UNION ALL
            SELECT 19, 327680, 640 UNION ALL
            SELECT 20, 163840, 1280 UNION ALL
            SELECT 21, 81920, 2560 UNION ALL
            SELECT 22, 40960, 5120 UNION ALL
            SELECT 23, 20480, 10240 UNION ALL
            SELECT 24, 10240, 20480 UNION ALL
            SELECT 25, 5120, 40960 UNION ALL
            SELECT 26, 2560, 81920 UNION ALL
            SELECT 27, 1280, 163840 UNION ALL
            SELECT 28, 640, 327680
        ),
        quadbinContext AS
        (
            SELECT *,
            @@RS_PREFIX@@carto.QUADBIN_FROMZXY(zoom, tileX, tileY) AS quadbin
            FROM tileContext
        )
        SELECT @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN(quadbin, zoom + 1) AS children
        FROM quadbinContext;"""
    )

    fixture_file = open('./test/integration/tochildren_fixtures/out/quadbins.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert result[0] == lines[idx].rstrip()


def test_tochildren_wrong_zoom_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            'SELECT @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN(8574853690513424384, 30)'
        )
    assert 'Wrong quadbin zoom' in str(excinfo.value)


def test_tochildren_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN(NULL, 1)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN(792633534417207296, NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
