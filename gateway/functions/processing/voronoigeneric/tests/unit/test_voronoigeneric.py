"""
Unit tests for VORONOIGENERIC function
"""

import json
from test_utils.unit import load_function_module

# Import shared library functions directly for testing
from processing import polygon_polygon_intersection, clip_segment_bbox

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["voronoigeneric"],
    },
)

voronoigeneric = imports["voronoigeneric"]
lambda_handler = imports["lambda_handler"]


class TestProcessingHelpers:
    """Test helper functions from the processing library (from clouds tests)"""

    def test_check_polygon_intersection(self):
        """Test polygon intersection calculation"""
        polygon1 = [[0, 0], [10, 0], [10, 10], [0, 10], [0, 0]]
        polygon2 = [[4, 4], [14, 2], [14, 8], [4, 6], [4, 4]]
        intersection1 = polygon_polygon_intersection(polygon1, polygon2)
        polygon1 = [[0, 0], [20, 0], [20, 20], [0, 20], [0, 0]]
        intersection2 = polygon_polygon_intersection(polygon1, polygon2)
        polygon2 = [[25, 5], [35, 0], [35, 15], [25, 10], [25, 5]]
        intersection3 = polygon_polygon_intersection(polygon1, polygon2)

        assert (
            str(intersection1) == "[[4, 4], [10.0, 2.8], [10.0, 7.2], [4, 6], [4, 4]]"
        )
        assert str(intersection2) == "[[4, 4], [14, 2], [14, 8], [4, 6], [4, 4]]"
        assert str(intersection3) == "[]"

    def test_check_clip_segment_bbox(self):
        """Test line segment clipping against bounding box"""
        linestring = [[2, 2], [12, 2]]
        bottom_left = [0, 0]
        upper_right = [10, 10]
        intersection1 = clip_segment_bbox(linestring, bottom_left, upper_right)
        linestring = [[12, 0], [16, 4]]
        intersection2 = clip_segment_bbox(linestring, bottom_left, upper_right)

        assert str(intersection1) == "[[2, 2], [10.0, 2.0]]"
        assert str(intersection2) == "[]"


class TestVoronoiGeneric:
    """Test the voronoigeneric function"""

    def test_simple_voronoi_lines(self):
        """Test basic voronoi with 'lines' output"""
        # Four points forming a square
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        bbox_json = "[-1,-1,2,2]"
        result_str = voronoigeneric(geom_json, bbox_json, "lines")
        result = json.loads(result_str)

        assert result["type"] == "MultiLineString"
        # Should have multiple line segments
        assert len(result["coordinates"]) > 0

    def test_simple_voronoi_poly(self):
        """Test basic voronoi with 'poly' output"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        bbox_json = "[-1,-1,2,2]"
        result_str = voronoigeneric(geom_json, bbox_json, "poly")
        result = json.loads(result_str)

        assert result["type"] == "MultiPolygon"
        # Should have multiple polygons (one per input point)
        assert len(result["coordinates"]) > 0

    def test_voronoi_without_bbox_lines(self):
        """Test voronoi without bounding box - lines output"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        result_str = voronoigeneric(geom_json, None, "lines")
        result = json.loads(result_str)

        assert result["type"] == "MultiLineString"
        assert len(result["coordinates"]) > 0

    def test_voronoi_without_bbox_poly(self):
        """Test voronoi without bounding box - poly output"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        result_str = voronoigeneric(geom_json, None, "poly")
        result = json.loads(result_str)

        assert result["type"] == "MultiPolygon"
        assert len(result["coordinates"]) > 0

    def test_null_points(self):
        """Test with null points input"""
        result = voronoigeneric(None, None, "lines")
        assert result is None

    def test_invalid_voronoi_type(self):
        """Test with invalid voronoi_type"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1]]}'
        result = voronoigeneric(geom_json, None, "invalid")
        assert result is None

    def test_invalid_bbox_length(self):
        """Test with invalid bbox (not 4 elements)"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1]]}'
        bbox_json = "[0,1,2]"  # Only 3 elements
        result = voronoigeneric(geom_json, bbox_json, "lines")
        assert result is None

    def test_three_points_triangle(self):
        """Test voronoi with three points forming a triangle"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[2,0],[1,2]]}'
        bbox_json = "[-1,-1,3,3]"
        result_str = voronoigeneric(geom_json, bbox_json, "poly")
        result = json.loads(result_str)

        assert result["type"] == "MultiPolygon"
        # Should have 3 polygons (one per point)
        assert len(result["coordinates"]) == 3


class TestLambdaHandler:
    """Test the Lambda handler function"""

    def test_empty_event(self):
        """Test handler with empty event"""
        event = {"arguments": [], "num_records": 0}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 0
        assert result["results"] == []

    def test_single_valid_row_lines(self):
        """Test handler with single valid row - lines output"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        bbox_json = "[-1,-1,2,2]"
        event = {"arguments": [[geom_json, bbox_json, "lines"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert len(result["results"]) == 1
        assert result["results"][0] is not None

        # Verify the result is valid JSON
        voronoi_result = json.loads(result["results"][0])
        assert voronoi_result["type"] == "MultiLineString"

    def test_single_valid_row_poly(self):
        """Test handler with single valid row - poly output"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        bbox_json = "[-1,-1,2,2]"
        event = {"arguments": [[geom_json, bbox_json, "poly"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is not None

        voronoi_result = json.loads(result["results"][0])
        assert voronoi_result["type"] == "MultiPolygon"

    def test_without_bbox(self):
        """Test handler without bounding box"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1]]}'
        event = {"arguments": [[geom_json, None, "lines"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is not None

    def test_null_geometry(self):
        """Test handler with null geometry"""
        event = {"arguments": [[None, None, "lines"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_invalid_voronoi_type(self):
        """Test handler with invalid voronoi_type"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1]]}'
        event = {"arguments": [[geom_json, None, "invalid"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_invalid_bbox(self):
        """Test handler with invalid bbox length"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1]]}'
        bbox_json = "[0,1,2]"
        event = {"arguments": [[geom_json, bbox_json, "lines"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        geom1 = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1]]}'
        geom2 = '{"type":"MultiPoint","coordinates":[[0,0],[2,0],[1,2]]}'
        bbox = "[-1,-1,3,3]"
        event = {
            "arguments": [
                [geom1, bbox, "lines"],
                [geom2, None, "poly"],
                [None, None, "lines"],
            ],
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

    def test_malformed_row(self):
        """Test handler with malformed row"""
        event = {"arguments": [None, ["single_value"], []], "num_records": 3}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert all(r is None for r in result["results"])
