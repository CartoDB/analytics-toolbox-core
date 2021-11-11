from test_utils import run_query, redshift_connector
import pytest


def test_polyfill_success():
    fixture_file = open(
        './test/integration/st_asquadint_polyfill_fixtures/in/wkts.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()
    feature_wkt = lines[0].rstrip()

    result = run_query(
        f"""SELECT @@RS_PREFIX@@carto.QUADINT_POLYFILL(
            ST_GeomFromText('{feature_wkt}'), 10) UNION ALL
        SELECT @@RS_PREFIX@@carto.QUADINT_POLYFILL(
            ST_GeomFromText('{feature_wkt}'), 14)"""
    )

    fixture_file = open(
        './test/integration/st_asquadint_polyfill_fixtures/out/quadints.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    # polifill10
    assert result[0][0] == lines[0].rstrip()
    # polyfill14
    assert result[1][0] == lines[1].rstrip()


def test_polyfill_collection_success():
    fixture_file = open(
        './test/integration/st_asquadint_polyfill_fixtures/in/wkts.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()
    feature_wkt = lines[1].rstrip()

    result = run_query(
        f"""SELECT @@RS_PREFIX@@carto.QUADINT_POLYFILL(
            ST_GeomFromText('{feature_wkt}'), 22)"""
    )

    fixture_file = open(
        './test/integration/st_asquadint_polyfill_fixtures/out/quadints.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    # polifill22
    assert result[0][0] == lines[2].rstrip()


def test_polyfill_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADINT_POLYFILL(NULL, 10)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)

    feature_wkt = 'POINT(10 2)'
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_PREFIX@@carto.QUADINT_POLYFILL(
                ST_GeomFromText('{feature_wkt}'), NULL)"""
        )
    assert 'NULL argument passed to UDF' in str(excinfo.value)
