# Copyright (c) 2026, CARTO

import json

from test_utils import run_query


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

# Expected values match the quadbin library (v0.2.2) used by Redshift,
# and BigQuery's QUADBIN_POLYFILL_MODE with 'intersects' mode.
EXPECTED_POLYGON_POLYFILL = sorted(
    [
        5265786693153193983,
        5265786693163941887,
        5265786693164204031,
        5265786693164466175,
        5265786693164728319,
        5265786693165514751,
    ]
)

EXPECTED_MULTI_POLYGON_POLYFILL = sorted(
    [
        5265786693074550783,
        5265786693075337215,
        5265786693153193983,
        5265786693163941887,
        5265786693164204031,
        5265786693164466175,
        5265786693164728319,
        5265786693164990463,
        5265786693165514751,
    ]
)


def _parse_polyfill(raw):
    """Parse a polyfill result into a sorted list of quadbin indices."""
    return sorted(json.loads(raw) if isinstance(raw, str) else raw)


def test_quadbin_polyfill_polygon():
    result = run_query(
        f'SELECT @@DB_SCHEMA@@.QUADBIN_POLYFILL('
        f"    ST_GEOMFROMTEXT('{POLYGON_WKT}', 4326), 17"
        f')'
    )

    polyfill = _parse_polyfill(result[0][0])
    assert polyfill == EXPECTED_POLYGON_POLYFILL


def test_quadbin_polyfill_multi_polygon():
    result = run_query(
        f'SELECT @@DB_SCHEMA@@.QUADBIN_POLYFILL('
        f"    ST_GEOMFROMTEXT('{MULTI_POLYGON_WKT}', 4326), 17"
        f')'
    )

    polyfill = _parse_polyfill(result[0][0])
    assert polyfill == EXPECTED_MULTI_POLYGON_POLYFILL


def test_quadbin_polyfill_null():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_POLYFILL(NULL, 17),'
        '    @@DB_SCHEMA@@.QUADBIN_POLYFILL('
        "        ST_GEOMFROMTEXT('POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))', 4326),"
        '        NULL'
        '    )'
    )

    assert result[0][0] is None
    assert result[0][1] is None
