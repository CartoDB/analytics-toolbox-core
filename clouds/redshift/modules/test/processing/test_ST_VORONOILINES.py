import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_voronoi_lines_success():
    with open(f'{here}/fixtures/st_voronoi_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    results = run_query(
        f"""SELECT @@RS_SCHEMA@@.ST_VORONOILINES(
            ST_GeomFromText('{lines[0].rstrip()}')),
        @@RS_SCHEMA@@.ST_VORONOILINES(
            ST_GeomFromText('{lines[1].rstrip()}'))"""
    )

    with open(f'{here}/fixtures/st_voronoi_lines_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_voronoi_lines_none():
    results = run_query(
        """SELECT @@RS_SCHEMA@@.ST_VORONOILINES(
            ST_GeomFromText(Null))"""
    )

    assert results[0][0] is None


def test_voronoi_lines_wrong_geom_type():
    with open(f'{here}/fixtures/st_voronoi_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_SCHEMA@@.ST_VORONOILINES(
                ST_GeomFromText('{lines[3].rstrip()}'))"""
        )

    assert 'Input points parameter must be MultiPoint' in str(excinfo.value)


def test_voronoi_lines_geom_too_long():
    with open(f'{here}/fixtures/st_voronoi_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_SCHEMA@@.ST_VORONOILINES(
                ST_GeomFromText('{lines[2].rstrip()}'))"""
        )

    assert 'Value too long for character type' in str(excinfo.value)


def test_voronoi_lines_default_not_succeed():
    with open(f'{here}/fixtures/st_voronoi_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_SCHEMA@@.ST_VORONOILINES(
                ST_GeomFromText('{lines[1].rstrip()}'), JSON_PARSE('[
                    -80.73611869702799,30.50013148785057,
                    -55.200433643307896, 41.019920879156246]'))"""
        )

    assert 'Points should be within the bounding box supplied' in str(excinfo.value)


def test_voronoi_lines_default():
    with open(f'{here}/fixtures/st_voronoi_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    results = run_query(
        f"""SELECT @@RS_SCHEMA@@.ST_VORONOILINES(
            ST_GeomFromText('{lines[0].rstrip()}'), JSON_PARSE('[-76.704999999999998,
            38.655000000000001, -74.594999999999999, 40.475000000000009]')),
        @@RS_SCHEMA@@.ST_VORONOILINES(
            ST_GeomFromText('{lines[0].rstrip()}'))"""
    )

    with open(f'{here}/fixtures/st_voronoi_lines_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    assert str(results[0][1]) == lines[0].rstrip()
    assert str(results[0][0]) == str(results[0][1])
