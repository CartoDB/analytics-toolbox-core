# Copyright (c) 2026, CARTO

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


# Note: In Oracle '' IS NULL, so the empty-string quadkey (zoom 0) cannot
# be passed to FROMQUADKEY. Use QUADBIN_FROMZXY(0, 0, 0) for zoom level 0.

QUADKEY_QUADBIN_PAIRS = [
    ('0', 5193776270265024511),
    ('13020310', 5226184719091105791),
    ('0231001222', 5233974874938015743),
]


def test_quadbin_fromquadkey():
    for quadkey, expected_quadbin in QUADKEY_QUADBIN_PAIRS:
        result = run_query(
            f"SELECT @@ORA_SCHEMA@@.QUADBIN_FROMQUADKEY('{quadkey}') FROM DUAL",
            fetch=True,
        )

        assert result[0][0] == expected_quadbin, (
            f"FROMQUADKEY('{quadkey}'): expected {expected_quadbin}, got {result[0][0]}"
        )


def test_quadbin_fromquadkey_null():
    """In Oracle '' IS NULL, so NULL input returns NULL (covers empty string)."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_FROMQUADKEY(NULL) FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None


def test_quadbin_fromquadkey_roundtrip():
    """Verify FROMQUADKEY -> TOQUADKEY roundtrip returns original quadkey."""
    for quadkey, _ in QUADKEY_QUADBIN_PAIRS:
        result = run_query(
            f"""SELECT @@ORA_SCHEMA@@.QUADBIN_TOQUADKEY(
                @@ORA_SCHEMA@@.QUADBIN_FROMQUADKEY('{quadkey}')
            ) FROM DUAL""",
            fetch=True,
        )

        assert result[0][0] == quadkey, (
            f"Roundtrip for '{quadkey}': expected '{quadkey}', got '{result[0][0]}'"
        )
