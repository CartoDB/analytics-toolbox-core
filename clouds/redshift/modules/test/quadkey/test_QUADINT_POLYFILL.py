import os
import pytest

from test_utils import run_query, ProgrammingError

here = os.path.dirname(__file__)


def test_polyfill_success():
    with open(f'{here}/fixtures/quadint_polyfill_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    fixture_file.close()
    feature_wkt = lines[0].rstrip()

    result = run_query(
        f"""SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(
            ST_GeomFromText('{feature_wkt}'), 10) UNION ALL
        SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(
            ST_GeomFromText('{feature_wkt}'), 14)"""
    )

    with open(f'{here}/fixtures/quadint_polyfill_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    # polifill10
    assert result[0][0] == lines[0].rstrip()
    # polyfill14
    assert result[1][0] == lines[1].rstrip()


def test_polyfill_collection_success():
    with open(f'{here}/fixtures/quadint_polyfill_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    feature_wkt = lines[1].rstrip()

    result = run_query(
        f"""SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(
            ST_GeomFromText('{feature_wkt}'), 22)"""
    )

    with open(f'{here}/fixtures/quadint_polyfill_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    # polifill22
    assert result[0][0] == lines[2].rstrip()


def test_polyfill_failure():
    with pytest.raises(ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(NULL, 10)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)

    feature_wkt = 'POINT(10 2)'
    with pytest.raises(ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(
                ST_GeomFromText('{feature_wkt}'), NULL)"""
        )
    assert 'NULL argument passed to UDF' in str(excinfo.value)
