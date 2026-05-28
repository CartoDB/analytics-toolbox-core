# Copyright (c) 2026, CARTO

import pytest

from test_utils import run_query


# Inputs and expected outputs are copied from the canonical quadbin
# library's test suite (the same library is bundled into the MLE module).
POINT = 'POINT(-3.7115216913662175 40.41092231814629)'
MULTI_POINT = (
    'MULTIPOINT ((-3.7115216913662175 40.41092231814629),'
    '(-3.7112427416286686 40.41200062990766),'
    '(-3.710985249563239 40.41080795073389))'
)
LINE = (
    'LINESTRING(-3.7142468157253483 40.40915777072141,'
    '-3.712337082906745 40.41110203797309,'
    '-3.711178368612311 40.40969694289874,'
    '-3.709290093465827 40.411396123927084)'
)
POLYGON = (
    'POLYGON ((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865))'
)
MULTI_POLYGON = (
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


def _polyfill(wkt, resolution):
    """Run QUADBIN_POLYFILL and return a sorted list of quadbin indices."""
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY('{wkt}'),
            {resolution}
        ))"""
    )
    if rows == 'No results returned' or rows is None:
        return []
    return sorted(int(r[0]) for r in rows)


@pytest.mark.parametrize(
    'resolution,wkt,output',
    [
        (
            17,
            POLYGON,
            [
                5265786693153193983,
                5265786693163941887,
                5265786693164204031,
                5265786693164466175,
                5265786693164728319,
                5265786693165514751,
            ],
        ),
        (
            17,
            MULTI_POLYGON,
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
            ],
        ),
    ],
    ids=['polygon', 'multipolygon'],
)
def test_quadbin_polyfill(resolution, wkt, output):
    assert _polyfill(wkt, resolution) == sorted(output)


def test_quadbin_polyfill_point():
    """Point geometry covers exactly one tile."""
    cells = _polyfill(POINT, 17)
    assert cells == [5265786693164466175]


def test_quadbin_polyfill_multi_point():
    cells = _polyfill(MULTI_POINT, 17)
    assert cells == sorted([5265786693163941887, 5265786693164466175])


def test_quadbin_polyfill_line():
    cells = _polyfill(LINE, 17)
    assert cells == sorted(
        [
            5265786693153193983,
            5265786693154766847,
            5265786693164466175,
            5265786693164728319,
        ]
    )


def test_quadbin_polyfill_null_geom():
    rows = run_query(
        """SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(NULL, 17))"""
    )
    assert rows == 'No results returned' or rows == [] or rows is None


def test_quadbin_polyfill_null_resolution():
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON}'), NULL
        ))"""
    )
    assert rows == 'No results returned' or rows == [] or rows is None


@pytest.mark.parametrize('resolution', [-1, 27])
def test_quadbin_polyfill_invalid_resolution(resolution):
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON}'), {resolution}
        ))"""
    )
    assert rows == 'No results returned' or rows == [] or rows is None
