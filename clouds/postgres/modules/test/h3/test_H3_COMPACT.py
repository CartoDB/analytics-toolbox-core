from test_utils import run_query


def test_h3_compact_null_values():
    """Returns empty arrays with null inputs."""
    result = run_query(
        """
            SELECT
                @@PG_SCHEMA@@.H3_COMPACT(NULL) as c,
                @@PG_SCHEMA@@.H3_UNCOMPACT(NULL, 5) as u
        """
    )
    assert len(result) == 1
    assert result[0][0] == []
    assert result[0][1] == []

    result = run_query(
        """
            SELECT
                @@PG_SCHEMA@@.H3_COMPACT(ARRAY[]::VARCHAR[16]) as c,
                @@PG_SCHEMA@@.H3_UNCOMPACT(ARRAY[]::VARCHAR[16], 5) as u
        """
    )
    assert len(result) == 1
    assert result[0][0] == []
    assert result[0][1] == []


def test_h3_compact_polyfill():
    """Works with polyfill arrays."""
    result = run_query(
        """
            WITH poly AS
            (
                SELECT @@PG_SCHEMA@@.H3_POLYFILL(ST_GEOMFROMTEXT('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))'), 9) AS v
            )
            SELECT
                ARRAY_LENGTH(v, 1) AS original,
                ARRAY_LENGTH(@@PG_SCHEMA@@.H3_COMPACT(v), 1) AS compacted,
                ARRAY_LENGTH(@@PG_SCHEMA@@.H3_UNCOMPACT(@@PG_SCHEMA@@.H3_COMPACT(v), 9), 1) AS uncompacted
            FROM poly
        """  # noqa
    )
    assert len(result) == 1
    assert result[0][0] == 1321
    assert result[0][1] == 211
    assert result[0][2] == 1321
