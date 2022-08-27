import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_polygonize_success():
    with open(f'{here}/fixtures/st_polygonize_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    results = run_query(
        f"""SELECT ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[0].rstrip()}'))),
       ST_AsText( @@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[1].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[2].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[3].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[4].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[5].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[6].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[7].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[8].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[9].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[10].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[11].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[12].rstrip()}'))),
        ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
            ST_GeomFromText('{lines[13].rstrip()}')))"""
    )

    with open(f'{here}/fixtures/st_polygonize_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_polygonize_wrong_parameter():
    with open(f'{here}/fixtures/st_polygonize_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
                ST_GeomFromText('{lines[15].rstrip()}')))"""
        )

    assert 'type found: POINT' in str(excinfo.value)

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
                ST_GeomFromText('{lines[16].rstrip()}')))"""
        )

    assert 'type found: POLYGON' in str(excinfo.value)


def test_polygonize_invalid_path():
    with open(f'{here}/fixtures/st_polygonize_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            f"""SELECT ST_AsText(@@RS_SCHEMA@@.ST_POLYGONIZE(
                ST_GeomFromText('{lines[14].rstrip()}')))"""
        )

    assert 'Input linestring must be closed' in str(excinfo.value)
