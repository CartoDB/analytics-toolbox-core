# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_boundary_null():
    """Returns NULL for NULL input."""
    result = run_query('SELECT @@ORA_SCHEMA@@.H3_BOUNDARY(NULL) FROM DUAL')
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_boundary_invalid():
    """Returns NULL for an invalid H3 index."""
    result = run_query("SELECT @@ORA_SCHEMA@@.H3_BOUNDARY('ff283473fffffff') FROM DUAL")
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_boundary_valid_not_null():
    """Returns a non-NULL geometry for a valid H3 index."""
    result = run_query("SELECT @@ORA_SCHEMA@@.H3_BOUNDARY('85283473fffffff') FROM DUAL")
    assert len(result) == 1
    assert result[0][0] is not None


def test_h3_boundary_is_polygon():
    """Returns a POLYGON geometry."""
    result = run_query(
        'SELECT TO_CHAR(SDO_UTIL.TO_WKTGEOMETRY('
        "@@ORA_SCHEMA@@.H3_BOUNDARY('85283473fffffff'))) FROM DUAL"
    )
    assert len(result) == 1
    wkt = result[0][0]
    assert wkt is not None
    assert 'POLYGON' in wkt.upper()


def test_h3_boundary_srid_4326():
    """Returns a geometry with SRID 4326."""
    result = run_query(
        'SELECT t.geom.SDO_SRID FROM'
        " (SELECT @@ORA_SCHEMA@@.H3_BOUNDARY('85283473fffffff')"
        ' AS geom FROM DUAL) t'
    )
    assert len(result) == 1
    assert result[0][0] == 4326


def test_h3_boundary_vertices():
    """Boundary vertices match the canonical h3-js output for `85283473fffffff`."""
    rows = run_query(
        'SELECT v.x, v.y FROM ('
        "  SELECT @@ORA_SCHEMA@@.H3_BOUNDARY('85283473fffffff') AS geom FROM DUAL"
        ') t, TABLE(SDO_UTIL.GETVERTICES(t.geom)) v ORDER BY v.id'
    )
    expected = [
        (-121.915080327056, 37.2713558667317),
        (-121.862223289025, 37.3539264508521),
        (-121.923549996301, 37.4283411860942),
        (-122.03773496427, 37.4201286776776),
        (-122.090428929044, 37.3375560843528),
        (-122.02910130919, 37.2631979746181),
        (-121.915080327056, 37.2713558667317),
    ]
    assert len(rows) == len(expected)
    tolerance = 1e-9
    for (got_x, got_y), (exp_x, exp_y) in zip(rows, expected):
        assert abs(got_x - exp_x) < tolerance, f'lon: got {got_x}, expected {exp_x}'
        assert abs(got_y - exp_y) < tolerance, f'lat: got {got_y}, expected {exp_y}'
