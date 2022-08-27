import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_delaunay_lines_success():
    with open(f'{here}/fixtures/st_delaunay_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    results = run_query(
        f"""SELECT @@RS_SCHEMA@@.ST_DELAUNAYLINES(
            ST_GeomFromText('{lines[0].rstrip()}')),
        @@RS_SCHEMA@@.ST_DELAUNAYLINES(
            ST_GeomFromText('{lines[1].rstrip()}'))"""
    )

    with open(f'{here}/fixtures/st_delaunay_lines_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_delaunay_lines_none():
    results = run_query(
        """SELECT @@RS_SCHEMA@@.ST_DELAUNAYLINES(
            ST_GeomFromText(Null))"""
    )

    assert results[0][0] is None


def test_delaunay_lines_wrong_geom_type():
    with open(f'{here}/fixtures/st_delaunay_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_SCHEMA@@.ST_DELAUNAYLINES(
                ST_GeomFromText('{lines[3].rstrip()}'))"""
        )

    assert 'Input points parameter must be MultiPoint' in str(excinfo.value)


def test_delaunay_lines_geom_too_long():
    with open(f'{here}/fixtures/st_delaunay_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_SCHEMA@@.ST_DELAUNAYLINES(
                ST_GeomFromText('{lines[2].rstrip()}'))"""
        )

    assert 'Value too long for character type' in str(excinfo.value)
