from test_utils import run_query, redshift_connector
import pytest


def test_voronoi_poly_success():
    fixture_file = open('./test/integration/voronoi_fixtures/in/wkts.txt', 'r')
    points = fixture_file.readlines()
    fixture_file.close()

    results = run_query(
        f"""SELECT @@RS_PREFIX@@processing.ST_VORONOIPOLYGONS(
            ST_GeomFromText('{points[0].rstrip()}')),
        @@RS_PREFIX@@processing.ST_VORONOIPOLYGONS(
            ST_GeomFromText('{points[1].rstrip()}'))"""
    )

    fixture_file = open(
        './test/integration/voronoi_fixtures/out/geojsons_poly.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_voronoi_poly_none():
    results = run_query(
        """SELECT @@RS_PREFIX@@processing.ST_VORONOIPOLYGONS(
            ST_GeomFromText(Null))"""
    )

    assert results[0][0] is None


def test_voronoi_poly_wrong_geom_type():
    fixture_file = open('./test/integration/voronoi_fixtures/in/wkts.txt', 'r')
    points = fixture_file.readlines()
    fixture_file.close()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_PREFIX@@processing.ST_VORONOIPOLYGONS(
                ST_GeomFromText('{points[3].rstrip()}'))"""
        )

    assert 'Input points parameter must be MultiPoint' in str(excinfo.value)


def test_voronoi_poly_geom_too_long():
    fixture_file = open('./test/integration/voronoi_fixtures/in/wkts.txt', 'r')
    points = fixture_file.readlines()
    fixture_file.close()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_PREFIX@@processing.ST_VORONOIPOLYGONS(
                ST_GeomFromText('{points[2].rstrip()}'))"""
        )

    assert 'Value too long for character type' in str(excinfo.value)


def test_voronoi_poly_default_not_succeed():
    fixture_file = open('./test/integration/voronoi_fixtures/in/wkts.txt', 'r')
    points = fixture_file.readlines()
    fixture_file.close()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT @@RS_PREFIX@@processing.ST_VORONOIPOLYGONS(
                ST_GeomFromText('{points[1].rstrip()}'), JSON_PARSE('[
                    -80.73611869702799, 30.50013148785057,
                    -55.200433643307896, 41.019920879156246]'))"""
        )

    assert 'Points should be within the bounding box supplied' in str(excinfo.value)


def test_voronoi_poly_default():
    fixture_file = open('./test/integration/voronoi_fixtures/in/wkts.txt', 'r')
    points = fixture_file.readlines()
    fixture_file.close()

    results = run_query(
        f"""SELECT @@RS_PREFIX@@processing.ST_VORONOIPOLYGONS(
            ST_GeomFromText('{points[0].rstrip()}'), JSON_PARSE('[-76.704999999999998,
            38.655000000000001, -74.594999999999999, 40.475000000000009]')),
        @@RS_PREFIX@@processing.ST_VORONOIPOLYGONS(
            ST_GeomFromText('{points[0].rstrip()}'))"""
    )

    fixture_file = open(
        './test/integration/voronoi_fixtures/out/geojsons_poly.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    assert str(results[0][1]) == lines[0].rstrip()
    assert str(results[0][0]) == str(results[0][1])
