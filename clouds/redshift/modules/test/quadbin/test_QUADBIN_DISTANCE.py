from test_utils import run_query


def test_quadbin_distance():
    result = run_query(
        'SELECT @@RS_SCHEMA@@.QUADBIN_DISTANCE'
        '(5207251884775047167, 5207128739472736255)'
    )

    assert len(result[0]) == 1
    assert result[0][0] == 1
