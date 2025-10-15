import json
from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["generatepoints"],
    },
)

generatepoints = imports["generatepoints"]
lambda_handler = imports["lambda_handler"]


class TestGeneratePoints:
    """Tests for the generatepoints core function"""

    def test_generatepoints_simple_polygon(self):
        """Test generating points in a simple square polygon"""
        geom = (
            '{"type": "Polygon", "coordinates": '
            "[[[0, 0], [0, 2], [2, 2], [2, 0], [0, 0]]]}"
        )
        result = generatepoints(geom, 10)
        result_json = json.loads(result)

        assert result_json["type"] == "MultiPoint"
        assert len(result_json["coordinates"]) == 10

        # Verify all points are within bounds [0, 2] x [0, 2]
        for coord in result_json["coordinates"]:
            assert 0 <= coord[0] <= 2
            assert 0 <= coord[1] <= 2

    def test_generatepoints_single_point(self):
        """Test generating a single point returns Point not MultiPoint"""
        geom = (
            '{"type": "Polygon", "coordinates": '
            "[[[0, 0], [0, 2], [2, 2], [2, 0], [0, 0]]]}"
        )
        result = generatepoints(geom, 1)
        result_json = json.loads(result)

        assert result_json["type"] == "Point"
        assert len(result_json["coordinates"]) == 2

        # Verify point is within bounds
        assert 0 <= result_json["coordinates"][0] <= 2
        assert 0 <= result_json["coordinates"][1] <= 2

    def test_generatepoints_triangle(self):
        """Test generating points in a triangular polygon"""
        geom = (
            '{"type": "Polygon", "coordinates": [[[0, 0], [1, 0], [0.5, 1], [0, 0]]]}'
        )
        result = generatepoints(geom, 5)
        result_json = json.loads(result)

        assert result_json["type"] == "MultiPoint"
        assert len(result_json["coordinates"]) == 5


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_lambda_handler_basic(self):
        """Test Lambda handler with basic input"""
        geom = (
            '{"type": "Polygon", "coordinates": '
            "[[[0, 0], [0, 2], [2, 2], [2, 0], [0, 0]]]}"
        )
        event = {"arguments": [[geom, 10]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert len(result["results"]) == 1
        assert result["results"][0] is not None

        # Verify the result is valid GeoJSON
        geojson_result = json.loads(result["results"][0])
        assert geojson_result["type"] == "MultiPoint"
        assert len(geojson_result["coordinates"]) == 10

    def test_lambda_handler_single_point(self):
        """Test Lambda handler with single point"""
        geom = (
            '{"type": "Polygon", "coordinates": '
            "[[[0, 0], [0, 2], [2, 2], [2, 0], [0, 0]]]}"
        )
        event = {"arguments": [[geom, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        geojson_result = json.loads(result["results"][0])
        assert geojson_result["type"] == "Point"
        assert len(geojson_result["coordinates"]) == 2

    def test_lambda_handler_null_inputs(self):
        """Test Lambda handler with null inputs"""
        event = {"arguments": [[None, 10]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_lambda_handler_batch(self):
        """Test Lambda handler with batch processing"""
        geom1 = (
            '{"type": "Polygon", "coordinates": '
            "[[[0, 0], [0, 2], [2, 2], [2, 0], [0, 0]]]}"
        )
        geom2 = (
            '{"type": "Polygon", "coordinates": '
            "[[[0, 0], [1, 0], [0.5, 1], [0, 0]]]}"
        )
        event = {
            "arguments": [[geom1, 5], [geom2, 3], [None, 10]],
            "num_records": 3,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 3
        assert len(result["results"]) == 3
        assert result["results"][0] is not None
        assert result["results"][1] is not None
        assert result["results"][2] is None
