from test_utils import run_query
import json


def test_quadbin_polyfill():
    polygon = (
        'POLYGON ((-363.71219873428345 40.413365349070865,'
        '-363.7144088745117 40.40965661286395,'
        '-363.70659828186035 40.409525904775634,'
        '-363.71219873428345 40.413365349070865))'
    )
    result = run_query(
        f"""SELECT @@RS_PREFIX@@carto.QUADBIN_POLYFILL(
            ST_GEOMFROMTEXT('{polygon}'),
            17
        ) AS output"""
    )

    assert len(result[0]) == 1
    assert (
        json.loads(result[0][0]).sort()
        == [
            5265786693164204031,
            5265786693163941887,
            5265786693153193983,
            5265786693164466175,
            5265786693164728319,
            5265786693165514751,
        ].sort()
    )
