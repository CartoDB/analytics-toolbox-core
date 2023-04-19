from test_utils import run_query


def test_h3_tochildren_invalid_data():
    """Returns empty arrays with invalid data."""
    result = run_query(
        """
            WITH ids AS
            (
                -- Invalid parameters
                SELECT 1 AS id, NULL as hid UNION ALL
                SELECT 2 AS id, 'ff283473fffffff' as hid
            )
            SELECT
                id,
                @@PG_SCHEMA@@.H3_TOCHILDREN(hid, 1) as parent
            FROM ids
            ORDER BY id ASC
        """
    )
    assert len(result) == 2
    assert result[0][1] == []
    assert result[1][1] == []


def test_h3_tochildren():
    """List children correctly."""
    result = run_query(
        """
            WITH ids AS
            (
                SELECT
                    @@PG_SCHEMA@@.H3_FROMGEOGPOINT(ST_POINT(-122.409290778685, 37.81331899988944), 7) AS hid
            )
            SELECT
                ARRAY_LENGTH(@@PG_SCHEMA@@.H3_TOCHILDREN(hid, 8), 1) AS length_children,
                ARRAY_LENGTH(@@PG_SCHEMA@@.H3_TOCHILDREN(hid, 9), 1) AS length_grandchildren
            FROM ids
        """  # noqa
    )

    assert len(result) == 1
    assert result[0][0] == 7
    assert result[0][1] == 49


def test_h3_tochildren_same_resolution():
    """List itself for same resolution."""
    result = run_query(
        """
            WITH ids AS
            (
                SELECT '87283080dffffff' as hid
            )
            SELECT
                @@PG_SCHEMA@@.H3_TOCHILDREN(hid, 7) AS self_children
            FROM ids
        """
    )
    assert len(result) == 1
    assert result[0][0] == ['87283080dffffff']


def test_h3_tochildren_coarser_resolutions():
    """Returns empty arrays for coarser resolutions."""
    result = run_query(
        """
            WITH ids AS
            (
                SELECT
                    @@PG_SCHEMA@@.H3_FROMGEOGPOINT(ST_POINT(-122.409290778685, 37.81331899988944), 7) AS hid
            )
            SELECT
                @@PG_SCHEMA@@.H3_TOCHILDREN(hid, 6) AS top_children
            FROM ids
        """  # noqa
    )
    assert len(result) == 1
    assert result[0][0] == []
