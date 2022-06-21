from test_utils import run_query, redshift_connector
import pytest


def test_toparent_success():
    result = run_query(
        """WITH zoomContext AS(
            SELECT 1 AS zoom, -150 AS long, 60 AS lat UNION ALL
            SELECT 2, 150, 60 UNION ALL
            SELECT 3, -150, -60 UNION ALL
            SELECT 4, 150, -60 UNION ALL
            SELECT 5, -30, 30 UNION ALL
            SELECT 6, 30, 30 UNION ALL
            SELECT 7, -30, -30 UNION ALL
            SELECT 8, 30, -30 UNION ALL
            SELECT 9, -100, 0 UNION ALL
            SELECT 10, 100, 0 UNION ALL
            SELECT 11, -100, 0 UNION ALL
            SELECT 12, 100, 0 UNION ALL
            SELECT 13, 0, 45 UNION ALL
            SELECT 14, 0, 45 UNION ALL
            SELECT 15, 0, -45 UNION ALL
            SELECT 16, 0, -45 UNION ALL
            SELECT 17, -70, 10 UNION ALL
            SELECT 18, 70, 10 UNION ALL
            SELECT 19, -70, -10 UNION ALL
            SELECT 20, 70, -10 UNION ALL
            SELECT 21, -10, 80 UNION ALL
            SELECT 22, 10, 80 UNION ALL
            SELECT 23, -10, -80 UNION ALL
            SELECT 24, 10, -80 UNION ALL
            SELECT 25, -45, 25 UNION ALL
            SELECT 26, 45, 25 UNION ALL
            SELECT 27, -45, -25 UNION ALL
            SELECT 28, 45, -25 UNION ALL
            SELECT 29, 0, 0
        )
        SELECT *
        FROM
        (
            SELECT
            @@RS_PREFIX@@carto.QUADBIN_FROMGEOGPOINT(
                ST_POINT(long, lat), zoom - 1) AS expectedParent,
            @@RS_PREFIX@@carto.QUADBIN_TOPARENT(
                @@RS_PREFIX@@carto.QUADBIN_FROMGEOGPOINT(
                    ST_POINT(long, lat), zoom),zoom - 1) AS parent
            FROM zoomContext
        )
        WHERE parent != expectedParent;"""
    )

    assert result == ()


def test_toparent_wrong_zoom_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_TOPARENT(0, 0)')
    assert 'Wrong quadbin zoom' in str(excinfo.value)


def test_toparent_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_TOPARENT(NULL, 10)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_TOPARENT(792633534417207296, NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
