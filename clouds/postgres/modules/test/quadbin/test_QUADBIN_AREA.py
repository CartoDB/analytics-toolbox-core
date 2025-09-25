from test_utils import run_query


def test_quadbin_area():
    """Computes area for quadbin."""
    result = run_query(
        'SELECT @@PG_SCHEMA@@.QUADBIN_AREA(5207251884775047167)'
    )

    # Area should be approximately 4.86e12 square meters (close to BigQuery result)
    area = result[0][0]
    assert area is not None
    assert area > 4.8e12
    assert area < 5.0e12


def test_quadbin_area_null():
    """Returns NULL for NULL input."""
    result = run_query(
        'SELECT @@PG_SCHEMA@@.QUADBIN_AREA(NULL)'
    )

    assert result[0][0] is None


def test_quadbin_area_different_zoom_levels():
    """Higher zoom levels should have smaller areas."""
    result = run_query(
        '''SELECT
            @@PG_SCHEMA@@.QUADBIN_AREA(5192650370358181887) AS level0_area,
            @@PG_SCHEMA@@.QUADBIN_AREA(5193776270265024511) AS level1_area,
            @@PG_SCHEMA@@.QUADBIN_AREA(5207251884775047167) AS level4_area
        '''
    )

    level0_area, level1_area, level4_area = result[0]

    # Higher zoom levels should have smaller areas
    assert level0_area > level1_area
    assert level1_area > level4_area

    # Check that all values are positive
    assert level0_area > 0
    assert level1_area > 0
    assert level4_area > 0