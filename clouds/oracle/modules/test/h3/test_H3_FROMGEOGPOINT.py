# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_fromgeogpoint_basic():
    """Returns correct H3 index for a known point."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.0553238, 37.3615593, NULL),"
        " NULL, NULL), 5) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '85283473fffffff'


def test_h3_fromgeogpoint_second_location():
    """Returns correct H3 index for a second known point."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-164.991559, 30.943387, NULL),"
        " NULL, NULL), 5) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '8547732ffffffff'


def test_h3_fromgeogpoint_resolution_15():
    """Returns correct H3 index at maximum resolution."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(71.52790329909925, 46.04189431883772, NULL),"
        " NULL, NULL), 15) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '8f2000000000000'


def test_h3_fromgeogpoint_null_point():
    """Returns NULL when point is NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT(NULL, 5) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromgeogpoint_null_resolution():
    """Returns NULL when resolution is NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.0553238, 37.3615593, NULL),"
        " NULL, NULL), NULL) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromgeogpoint_invalid_resolution_negative():
    """Returns NULL for negative resolution."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.0553238, 37.3615593, NULL),"
        " NULL, NULL), -1) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromgeogpoint_invalid_resolution_too_high():
    """Returns NULL for resolution above 15."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.0553238, 37.3615593, NULL),"
        " NULL, NULL), 20) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromgeogpoint_linestring():
    """Returns NULL for a LINESTRING geometry (non-point)."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2002, 4326, NULL,"
        " SDO_ELEM_INFO_ARRAY(1, 2, 1),"
        " SDO_ORDINATE_ARRAY(0, 0, 10, 10)), 5) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromgeogpoint_polygon():
    """Returns NULL for a POLYGON geometry (non-point)."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2003, 4326, NULL,"
        " SDO_ELEM_INFO_ARRAY(1, 1003, 1),"
        " SDO_ORDINATE_ARRAY(0, 0, 0, 10, 10, 10, 10, 0, 0, 0)), 5)"
        " FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromgeogpoint_non_wgs84_srid():
    """Returns NULL when point's explicit SRID is not 4326."""
    # SRID 3857 (Web Mercator) is rejected; H3 expects WGS84 inputs and
    # the function does not auto-transform.
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 3857,"
        " SDO_POINT_TYPE(-122.0553238, 37.3615593, NULL),"
        " NULL, NULL), 5) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromgeogpoint_null_srid_accepted():
    """Accepts a NULL SRID and treats the point as WGS84."""
    # SDO_UTIL.FROM_WKTGEOMETRY produces NULL-SRID geometries; we must
    # not reject those.
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, NULL,"
        " SDO_POINT_TYPE(-122.0553238, 37.3615593, NULL),"
        " NULL, NULL), 5) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '85283473fffffff'


def test_h3_fromgeogpoint_multipoint():
    """Returns NULL for a MULTIPOINT geometry (non-point)."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2005, 4326, NULL,"
        " SDO_ELEM_INFO_ARRAY(1, 1, 1, 3, 1, 1),"
        " SDO_ORDINATE_ARRAY(0, 0, 10, 10)), 5) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None
