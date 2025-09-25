from test_utils import run_query


def test_quadbin_area():
    result = run_query(
        'SELECT @@RS_SCHEMA@@.QUADBIN_AREA(5207251884775047167)'
    )

    assert len(result[0]) == 1
    # Area should be approximately 428 square units (Redshift ST_AREA units)
    area = result[0][0]
    assert area is not None
    assert area > 400
    assert area < 500


def test_quadbin_area_null():
    result = run_query(
        'SELECT @@RS_SCHEMA@@.QUADBIN_AREA(NULL)'
    )

    assert len(result[0]) == 1
    assert result[0][0] is None


def test_quadbin_area_different_zoom_levels():
    result = run_query(
        '''SELECT
            @@RS_SCHEMA@@.QUADBIN_AREA(5192650370358181887) AS level0_area,
            @@RS_SCHEMA@@.QUADBIN_AREA(5193776270265024511) AS level1_area,
            @@RS_SCHEMA@@.QUADBIN_AREA(5207251884775047167) AS level4_area
        '''
    )

    assert len(result[0]) == 3
    level0_area, level1_area, level4_area = result[0]

    # Higher zoom levels should have smaller areas
    assert level0_area > level1_area
    assert level1_area > level4_area

    # Check that all values are positive
    assert level0_area > 0
    assert level1_area > 0
    assert level4_area > 0