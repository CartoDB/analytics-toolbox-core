import os
import pytest

from test_utils import run_query, ProgrammingError

here = os.path.dirname(__file__)


def test_quadkey_conversion_success():
    result = run_query(
        """SELECT @@RS_SCHEMA@@.QUADINT_TOQUADKEY(
        @@RS_SCHEMA@@.QUADINT_FROMZXY(2, 1, 1)) as quadkey1,
        @@RS_SCHEMA@@.QUADINT_TOQUADKEY(
        @@RS_SCHEMA@@.QUADINT_FROMZXY(6, 40, 55)) as quadkey2,
        @@RS_SCHEMA@@.QUADINT_TOQUADKEY(
        @@RS_SCHEMA@@.QUADINT_FROMZXY(12, 1960, 3612)) as quadkey3,
        @@RS_SCHEMA@@.QUADINT_TOQUADKEY(
        @@RS_SCHEMA@@.QUADINT_FROMZXY(18, 131621, 65120)) as quadkey4,
        @@RS_SCHEMA@@.QUADINT_TOQUADKEY(
        @@RS_SCHEMA@@.QUADINT_FROMZXY(24, 9123432, 159830174)) as quadkey5,
        @@RS_SCHEMA@@.QUADINT_TOQUADKEY(
        @@RS_SCHEMA@@.QUADINT_FROMZXY(29, 389462872, 207468912)) as quadkey6"""
    )

    assert result[0][0] == '03'
    assert result[0][1] == '321222'
    assert result[0][2] == '233110123200'
    assert result[0][3] == '102222223002300101'
    assert result[0][4] == '300012312213011021123220'
    assert result[0][5] == '12311021323123033301303231000'


def test_quadint_decoding_success():
    results = run_query(
        """WITH tileContext AS(
            SELECT 0 AS zoom, 0 AS tileX, 0 AS tileY UNION ALL
            SELECT 1, 1, 1 UNION ALL
            SELECT 2, 2, 3 UNION ALL
            SELECT 3, 4, 5 UNION ALL
            SELECT 4, 6, 8 UNION ALL
            SELECT 5, 10, 20 UNION ALL
            SELECT 6, 40, 50 UNION ALL
            SELECT 7, 80, 90 UNION ALL
            SELECT 8, 160, 170 UNION ALL
            SELECT 9, 320, 320 UNION ALL
            SELECT 10, 640, 160 UNION ALL
            SELECT 11, 1280, 640 UNION ALL
            SELECT 12, 2560, 1280 UNION ALL
            SELECT 13, 5120, 160 UNION ALL
            SELECT 14, 10240, 80 UNION ALL
            SELECT 15, 20480, 40 UNION ALL
            SELECT 16, 40960, 80 UNION ALL
            SELECT 17, 81920, 160 UNION ALL
            SELECT 18, 163840, 320 UNION ALL
            SELECT 19, 327680, 640 UNION ALL
            SELECT 20, 163840, 1280 UNION ALL
            SELECT 21, 81920, 2560 UNION ALL
            SELECT 22, 40960, 5120 UNION ALL
            SELECT 23, 20480, 10240 UNION ALL
            SELECT 24, 10240, 20480 UNION ALL
            SELECT 25, 5120, 40960 UNION ALL
            SELECT 26, 2560, 81920 UNION ALL
            SELECT 27, 1280, 163840 UNION ALL
            SELECT 28, 640, 327680 UNION ALL
            SELECT 29, 327680, 327680
        )
        SELECT @@RS_SCHEMA@@.QUADINT_TOZXY(
            @@RS_SCHEMA@@.QUADINT_FROMQUADKEY(
                @@RS_SCHEMA@@.QUADINT_TOQUADKEY(
                    @@RS_SCHEMA@@.QUADINT_FROMZXY(
                        zoom, tileX, tileY)))) AS decodedQuadkey
        FROM tileContext;"""
    )

    with open(f'{here}/fixtures/quadint_tozxy_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_quadint_null_failure():
    with pytest.raises(ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.QUADINT_TOQUADKEY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
