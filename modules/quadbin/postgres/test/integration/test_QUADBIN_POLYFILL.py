# flake8: noqa
from test_utils import run_query


def test_quadbin_polyfill():
    """Computes kring"""
    result = run_query(
        """
      SELECT QUADBIN_POLYFILL(
        ST_GeomFromText(
          'POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'
        )
        ,17
      )"""
    )
    expected = sorted(
        [
            5265786693153193983,
            5265786693163941887,
            5265786693164466175,
            5265786693164204031,
            5265786693164728319,
            5265786693165514751,
        ]
    )
    assert sorted(result[0][0]) == expected
