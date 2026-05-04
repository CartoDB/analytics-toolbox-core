# Copyright (c) 2026, CARTO
import pytest
from test_utils import run_query


# Test geometries (WKT)
POLYGON_WKT = (
    'POLYGON ((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865))'
)

MULTI_POLYGON_WKT = (
    'MULTIPOLYGON (((-3.7102890014648438 40.412768896581476,'
    '-3.7081432342529297 40.41124946964811,'
    '-3.707242012023926 40.41370014129302,'
    '-3.7102890014648438 40.412768896581476)),'
    '((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865),'
    '(-3.7122470136178776 40.41158984452673,'
    '-3.710165619422321 40.41109970196702,'
    '-3.711882233191852 40.41018475963737,'
    '-3.7122470136178776 40.41158984452673)))'
)

POINT_WKT = 'POINT(-3.7115216913662175 40.41092231814629)'

LINE_WKT = (
    'LINESTRING(-3.7142468157253483 40.40915777072141,'
    '-3.712337082906745 40.41110203797309,'
    '-3.711178368612311 40.40969694289874,'
    '-3.709290093465827 40.411396123927084)'
)


def _polyfill_mode(wkt, resolution, mode):
    """Run H3_POLYFILL_MODE as a TABLE and return the list of cells."""
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_POLYFILL_MODE('
        f"SDO_UTIL.FROM_WKTGEOMETRY('{wkt}'), {resolution}, '{mode}'))"
    )
    return [r[0] for r in run_query(sql)]


# ---------------------------------------------------------------------
# NULL / out-of-range / unknown-mode handling
# ---------------------------------------------------------------------


def test_h3_polyfill_mode_null_geom():
    """NULL geometry returns no rows."""
    sql = (
        'SELECT COLUMN_VALUE FROM TABLE('
        "@@ORA_SCHEMA@@.H3_POLYFILL_MODE(NULL, 9, 'center'))"
    )
    assert run_query(sql) == []


def test_h3_polyfill_mode_null_resolution():
    """NULL resolution returns no rows."""
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_POLYFILL_MODE('
        f"SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), NULL, 'center'))"
    )
    assert run_query(sql) == []


def test_h3_polyfill_mode_resolution_out_of_range():
    """Resolution outside 0-15 returns no rows in any mode."""
    assert _polyfill_mode(POLYGON_WKT, -1, 'center') == []
    assert _polyfill_mode(POLYGON_WKT, 16, 'intersects') == []
    assert _polyfill_mode(POLYGON_WKT, 99, 'contains') == []


def test_h3_polyfill_mode_invalid_returns_empty():
    """Unknown mode returns no rows."""
    assert _polyfill_mode(POLYGON_WKT, 9, 'bogus') == []


# ---------------------------------------------------------------------
# Non-polygon inputs are silently ignored — the H3_POLYFILL_MODE doc
# page documents this contract.
# ---------------------------------------------------------------------


def test_h3_polyfill_mode_point_returns_empty():
    """Point geometry returns no rows in any mode."""
    assert _polyfill_mode(POINT_WKT, 9, 'center') == []
    assert _polyfill_mode(POINT_WKT, 9, 'intersects') == []
    assert _polyfill_mode(POINT_WKT, 9, 'contains') == []


def test_h3_polyfill_mode_line_returns_empty():
    """Linestring geometry returns no rows in any mode."""
    assert _polyfill_mode(LINE_WKT, 8, 'center') == []
    assert _polyfill_mode(LINE_WKT, 8, 'intersects') == []
    assert _polyfill_mode(LINE_WKT, 8, 'contains') == []


# ---------------------------------------------------------------------
# Polygon coverage modes — exact fixture parity with the reference
# clouds. Same h3-js polyfill (CENTER) under the hood, plus an
# SDO_GEOM.RELATE post-filter for the intersects/contains variants.
# ---------------------------------------------------------------------


@pytest.mark.parametrize(
    'label,wkt,resolution,mode,expected',
    [
        ('Polygon center 9', POLYGON_WKT, 9, 'center', ['89390cb1b4bffff']),
        (
            'Polygon contains 10',
            POLYGON_WKT,
            10,
            'contains',
            ['8a390cb1b487fff', '8a390cb1b4b7fff'],
        ),
        (
            'Polygon intersects 9',
            POLYGON_WKT,
            9,
            'intersects',
            [
                '89390ca3487ffff',
                '89390ca3497ffff',
                '89390ca34b3ffff',
                '89390cb1b4bffff',
                '89390cb1b4fffff',
                '89390cb1b5bffff',
            ],
        ),
        (
            'MultiPolygon center 9',
            MULTI_POLYGON_WKT,
            9,
            'center',
            ['89390cb1b4bffff'],
        ),
        (
            'MultiPolygon contains 10',
            MULTI_POLYGON_WKT,
            10,
            'contains',
            [],
        ),
        (
            'MultiPolygon intersects 9',
            MULTI_POLYGON_WKT,
            9,
            'intersects',
            [
                '89390ca3487ffff',
                '89390ca3497ffff',
                '89390ca34b3ffff',
                '89390cb1b43ffff',
                '89390cb1b4bffff',
                '89390cb1b4fffff',
                '89390cb1b5bffff',
            ],
        ),
    ],
)
def test_h3_polyfill_mode_fixtures(label, wkt, resolution, mode, expected):
    """H3_POLYFILL_MODE polygon fixture matrix — exact cell sets."""
    cells = sorted(_polyfill_mode(wkt, resolution, mode))
    assert cells == sorted(
        expected
    ), f'{label}: got {cells}, expected {sorted(expected)}'


def test_h3_polyfill_mode_center_matches_h3_polyfill():
    """Center mode of H3_POLYFILL_MODE must match H3_POLYFILL output exactly."""
    polyfill_sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_POLYFILL('
        f"SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), 9))"
    )
    polyfill_cells = sorted(r[0] for r in run_query(polyfill_sql))
    mode_cells = sorted(_polyfill_mode(POLYGON_WKT, 9, 'center'))
    assert polyfill_cells == mode_cells


def test_h3_polyfill_mode_contains_subset_of_intersects():
    """For any polygon, contains-mode cells must be a subset of intersects."""
    contains = set(_polyfill_mode(MULTI_POLYGON_WKT, 9, 'contains'))
    intersects = set(_polyfill_mode(MULTI_POLYGON_WKT, 9, 'intersects'))
    assert contains.issubset(intersects)


def test_h3_polyfill_mode_center_subset_of_intersects():
    """For any polygon, center-mode cells must be a subset of intersects."""
    center = set(_polyfill_mode(MULTI_POLYGON_WKT, 9, 'center'))
    intersects = set(_polyfill_mode(MULTI_POLYGON_WKT, 9, 'intersects'))
    assert center.issubset(intersects)
