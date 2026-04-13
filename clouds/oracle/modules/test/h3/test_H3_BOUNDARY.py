# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_boundary_null():
    """Returns NULL for NULL input."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_BOUNDARY(NULL) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_boundary_invalid():
    """Returns NULL for an invalid H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_BOUNDARY('ff283473fffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_boundary_valid_not_null():
    """Returns a non-NULL geometry for a valid H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_BOUNDARY('85283473fffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is not None


def test_h3_boundary_is_polygon():
    """Returns a POLYGON geometry."""
    result = run_query(
        "SELECT TO_CHAR(SDO_UTIL.TO_WKTGEOMETRY("
        "@@ORA_SCHEMA@@.H3_BOUNDARY('85283473fffffff'))) FROM DUAL"
    )
    assert len(result) == 1
    wkt = result[0][0]
    assert wkt is not None
    assert 'POLYGON' in wkt.upper()


def test_h3_boundary_srid_4326():
    """Returns a geometry with SRID 4326."""
    result = run_query(
        "SELECT t.geom.SDO_SRID FROM"
        " (SELECT @@ORA_SCHEMA@@.H3_BOUNDARY('85283473fffffff')"
        " AS geom FROM DUAL) t"
    )
    assert len(result) == 1
    assert result[0][0] == 4326
