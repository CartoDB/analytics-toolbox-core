from test_utils import run_query
import json


def test_quadbin_boundary():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_BOUNDARY(
                5209574053332910079) AS output"""
    )

    assert len(result[0]) == 1
    assert json.loads(result[0][0]) == {
        'type': 'Polygon',
        'coordinates': [
            [
                [22.5, -21.943045533438177],
                [22.5, 0.0],
                [45.0, 0.0],
                [45.0, -21.943045533438177],
                [22.5, -21.943045533438177],
            ]
        ],
    }
