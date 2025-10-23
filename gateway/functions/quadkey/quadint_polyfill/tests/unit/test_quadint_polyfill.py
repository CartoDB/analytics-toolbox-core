"""Unit tests for QUADINT_POLYFILL function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_polyfill_basic(self):
        """Test basic polyfill"""
        # Simple polygon
        geojson = json.dumps(
            {
                "type": "Polygon",
                "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]],
            }
        )

        event = {"arguments": [[geojson, 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        quadints = json.loads(result["results"][0])
        assert isinstance(quadints, list)
        assert len(quadints) > 0
        # All should be integers
        assert all(isinstance(q, int) for q in quadints)

    def test_quadint_polyfill_point(self):
        """Test polyfill with point"""
        geojson = json.dumps({"type": "Point", "coordinates": [0, 0]})

        event = {"arguments": [[geojson, 10]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        quadints = json.loads(result["results"][0])
        assert isinstance(quadints, list)
        assert len(quadints) >= 1

    def test_quadint_polyfill_geometry_collection(self):
        """Test polyfill with GeometryCollection"""
        geojson = json.dumps(
            {
                "type": "GeometryCollection",
                "geometries": [
                    {"type": "Point", "coordinates": [0, 0]},
                    {"type": "Point", "coordinates": [1, 1]},
                ],
            }
        )

        event = {"arguments": [[geojson, 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        quadints = json.loads(result["results"][0])
        assert isinstance(quadints, list)
        assert len(quadints) >= 1
        # Should have unique quadints (GeometryCollection deduplicates)
        assert len(quadints) == len(set(quadints))

    def test_quadint_polyfill_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]
