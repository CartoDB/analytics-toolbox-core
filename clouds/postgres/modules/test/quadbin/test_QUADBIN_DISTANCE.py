from test_utils import run_query


def test_quadbin_resolution():
    """Computes distance between quadbins."""
    result = run_query(
        'SELECT @@PG_SCHEMA@@.QUADBIN_DISTANCE'
        '(5207251884775047167, 5207128739472736255)'
    )
    assert result[0][0] == 1
