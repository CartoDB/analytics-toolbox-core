"""
Unit tests for CLUSTERKMEANS function
"""

import json
import pytest
import importlib.util
from pathlib import Path
import numpy as np

# Load the handler module from the specific path
handler_path = (
    Path(__file__).parent.parent.parent / "code" / "lambda" / "python" / "handler.py"
)
spec = importlib.util.spec_from_file_location("clusterkmeans_handler", handler_path)
handler = importlib.util.module_from_spec(spec)
spec.loader.exec_module(handler)

# Extract the functions we need
KMeans = handler.KMeans
reorder_coords = handler.reorder_coords
count_distinct_coords = handler.count_distinct_coords
extract_coords_from_geojson = handler.extract_coords_from_geojson
clusterkmeans = handler.clusterkmeans
lambda_handler = handler.lambda_handler


class TestKMeans:
    """Test the KMeans algorithm"""

    def test_simple_clustering(self):
        """Test basic 2-cluster case"""
        points = np.array([[0, 0], [1, 1], [5, 5], [6, 6]])
        kmeans = KMeans()
        cluster_idx, centers, loss = kmeans(points, 2)

        # Should have 2 clusters
        assert len(np.unique(cluster_idx)) == 2
        # First two points should be in one cluster, last two in another
        assert cluster_idx[0] == cluster_idx[1]
        assert cluster_idx[2] == cluster_idx[3]
        assert cluster_idx[0] != cluster_idx[2]

    def test_single_cluster(self):
        """Test with k=1"""
        points = np.array([[0, 0], [1, 1], [2, 2]])
        kmeans = KMeans()
        cluster_idx, centers, loss = kmeans(points, 1)

        # All points should be in cluster 0
        assert all(cluster_idx == 0)


class TestHelperFunctions:
    """Test helper functions"""

    def test_reorder_coords_with_duplicates(self):
        """Test reordering with duplicates - unique coords should come first"""
        coords = np.array([[0, 0], [0, 0], [1, 1], [1, 1], [2, 2]])
        result = reorder_coords(coords)
        assert len(result) == 5
        # First 3 should be unique coords
        unique_coords = [tuple(c) for c in result[:3]]
        assert (0.0, 0.0) in unique_coords
        assert (1.0, 1.0) in unique_coords
        assert (2.0, 2.0) in unique_coords

    def test_count_distinct_coords(self):
        """Test counting distinct coordinates"""
        coords = np.array([[0, 0], [0, 0], [1, 1], [1, 1], [2, 2]])
        count = count_distinct_coords(coords)
        assert count == 3

    def test_extract_coords_from_point(self):
        """Test extracting coords from Point geometry"""
        geom = {"type": "Point", "coordinates": [1, 2]}
        coords = extract_coords_from_geojson(geom)
        assert coords == [[1, 2]]

    def test_extract_coords_from_multipoint(self):
        """Test extracting coords from MultiPoint geometry"""
        geom = {"type": "MultiPoint", "coordinates": [[0, 0], [1, 1], [2, 2]]}
        coords = extract_coords_from_geojson(geom)
        assert coords == [[0, 0], [1, 1], [2, 2]]

    def test_extract_coords_from_linestring(self):
        """Test extracting coords from LineString geometry"""
        geom = {"type": "LineString", "coordinates": [[0, 0], [1, 1], [2, 2]]}
        coords = extract_coords_from_geojson(geom)
        assert coords == [[0, 0], [1, 1], [2, 2]]


class TestClusterKMeans:
    """Test the clusterkmeans function"""

    def test_basic_clustering(self):
        """Test basic clustering with 2 clusters"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,1],[5,5],[6,6]]}'
        result_str = clusterkmeans(geom_json, 2)
        result = json.loads(result_str)

        # Should have 4 results (one per point)
        assert len(result) == 4
        # Each result should have 'cluster' and 'geom'
        for item in result:
            assert "cluster" in item
            assert "geom" in item
            assert 0 <= item["cluster"] < 2
            assert item["geom"]["type"] == "Point"
            assert len(item["geom"]["coordinates"]) == 2

    def test_more_clusters_than_points(self):
        """Test when k > number of points - should use k = num points"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,1]]}'
        result_str = clusterkmeans(geom_json, 10)
        result = json.loads(result_str)

        # Should have 2 results
        assert len(result) == 2
        # Clusters should be capped at 2
        clusters = set(item["cluster"] for item in result)
        assert len(clusters) <= 2

    def test_single_point(self):
        """Test with single point"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0]]}'
        result_str = clusterkmeans(geom_json, 1)
        result = json.loads(result_str)

        assert len(result) == 1
        assert result[0]["cluster"] == 0
        assert result[0]["geom"]["coordinates"] == [0.0, 0.0]

    def test_invalid_geometry_type(self):
        """Test that non-MultiPoint raises error"""
        geom_json = '{"type":"Point","coordinates":[0,0]}'
        with pytest.raises(ValueError, match="must be MultiPoint"):
            clusterkmeans(geom_json, 2)

    def test_duplicated_coordinates(self):
        """Test clustering with duplicated coordinates"""
        # Input has duplicates - should still cluster correctly
        geom_json = (
            '{"type":"MultiPoint","coordinates":'
            "[[0,0],[0,0],[0,0],[0,1],[0,1],[0,1],[5,0]]}"
        )
        result_str = clusterkmeans(geom_json, 3)
        result = json.loads(result_str)

        # Should have 7 results (one per input point)
        assert len(result) == 7
        # Should have 3 unique clusters
        clusters = set(item["cluster"] for item in result)
        assert len(clusters) == 3


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

    def test_single_valid_row(self):
        """Test handler with single valid row"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,1],[5,5],[6,6]]}'
        event = {"arguments": [[geom_json, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert len(result["results"]) == 1
        assert result["results"][0] is not None

        # Verify the result is valid JSON
        cluster_result = json.loads(result["results"][0])
        assert len(cluster_result) == 4

    def test_null_geometry(self):
        """Test handler with null geometry"""
        event = {"arguments": [[None, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_null_k(self):
        """Test handler with null k"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,1]]}'
        event = {"arguments": [[geom_json, None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        geom1 = '{"type":"MultiPoint","coordinates":[[0,0],[1,1],[5,5],[6,6]]}'
        geom2 = '{"type":"MultiPoint","coordinates":[[0,0],[1,1]]}'
        event = {
            "arguments": [[geom1, 2], [geom2, 1], [None, 2]],
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

    def test_invalid_geometry_type_returns_none(self):
        """Test handler with invalid geometry type returns None"""
        geom_json = '{"type":"Point","coordinates":[0,0]}'
        event = {"arguments": [[geom_json, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        # Should return None for invalid geometry type
        assert result["results"][0] is None
