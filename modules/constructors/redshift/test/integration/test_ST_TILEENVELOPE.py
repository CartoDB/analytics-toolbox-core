from test_utils import run_query, redshift_connector
import pytest


def test_tileenvelope_success():
    results = run_query(
        """SELECT @@RS_PREFIX@@carto.ST_TILEENVELOPE(10, 384, 368),
        @@RS_PREFIX@@carto.ST_TILEENVELOPE(18, 98304, 94299),
        @@RS_PREFIX@@carto.ST_TILEENVELOPE(25, 12582912, 12070369)"""
    )

    fixture_file = open(
        './test/integration/st_tileenvelope_fixtures/out/geojsons.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_tileenvelope_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.ST_TILEENVELOPE(10, 384, null)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
