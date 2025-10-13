"""
Unit tests for CLUSTERKMEANSTABLE function
"""

import json
import importlib.util
from pathlib import Path
import numpy as np

# Load the handler module from the specific path
handler_path = (
    Path(__file__).parent.parent.parent / "code" / "lambda" / "python" / "handler.py"
)
spec = importlib.util.spec_from_file_location(
    "clusterkmeanstable_handler", handler_path
)
handler = importlib.util.module_from_spec(spec)
spec.loader.exec_module(handler)

# Extract the functions we need
KMeans = handler.KMeans
reorder_coords = handler.reorder_coords
count_distinct_coords = handler.count_distinct_coords
clusterkmeanstable = handler.clusterkmeanstable
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

    def test_pairwise_distance(self):
        """Test pairwise distance calculation"""
        kmeans = KMeans()
        x = np.array([[0, 0], [1, 1]])
        y = np.array([[0, 0], [2, 2]])

        dists = kmeans.pairwise_dist(x, y)

        # Distance from (0,0) to (0,0) should be 0
        assert np.isclose(dists[0, 0], 0)
        # Distance from (1,1) to (2,2) should be sqrt(2)
        assert np.isclose(dists[1, 1], np.sqrt(2))


class TestHelperFunctions:
    """Test helper functions"""

    def test_reorder_coords_no_duplicates(self):
        """Test reordering with no duplicates"""
        coords = np.array([[0, 0], [1, 1], [2, 2]])
        result = reorder_coords(coords)
        assert len(result) == 3
        assert np.array_equal(result, coords)

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

    def test_count_distinct_coords_all_unique(self):
        """Test counting when all coords are unique"""
        coords = np.array([[0, 0], [1, 1], [2, 2]])
        count = count_distinct_coords(coords)
        assert count == 3


class TestClusterKMeansTable:
    """Test the clusterkmeanstable function"""

    def test_basic_clustering(self):
        """Test basic clustering with 2 clusters"""
        geom_json = '{"_coords":[0.0,0.0,1.0,1.0,5.0,5.0,6.0,6.0]}'
        result_str = clusterkmeanstable(geom_json, 2)
        result = json.loads(result_str)

        # Should have 4 results (one per point)
        assert len(result) == 4
        # Each result should have 'c' (cluster) and 'i' (index)
        for item in result:
            assert "c" in item
            assert "i" in item
            assert 0 <= item["c"] < 2
            assert 1 <= item["i"] <= 4

    def test_more_clusters_than_points(self):
        """Test when k > number of points - should use k = num points"""
        geom_json = '{"_coords":[0.0,0.0,1.0,1.0]}'
        result_str = clusterkmeanstable(geom_json, 10)
        result = json.loads(result_str)

        # Should have 2 results
        assert len(result) == 2
        # Clusters should be 0 and 1 (k is capped at 2)
        clusters = set(item["c"] for item in result)
        assert len(clusters) <= 2

    def test_single_point(self):
        """Test with single point"""
        geom_json = '{"_coords":[0.0,0.0]}'
        result_str = clusterkmeanstable(geom_json, 1)
        result = json.loads(result_str)

        assert len(result) == 1
        assert result[0]["c"] == 0
        assert result[0]["i"] == 1

    def test_indices_are_one_based(self):
        """Test that indices start at 1, not 0"""
        geom_json = '{"_coords":[0.0,0.0,1.0,1.0,2.0,2.0]}'
        result_str = clusterkmeanstable(geom_json, 2)
        result = json.loads(result_str)

        indices = [item["i"] for item in result]
        assert indices == [1, 2, 3]


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
        geom_json = '{"_coords":[0.0,0.0,1.0,1.0,5.0,5.0,6.0,6.0]}'
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
        geom_json = '{"_coords":[0.0,0.0,1.0,1.0]}'
        event = {"arguments": [[geom_json, None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        geom1 = '{"_coords":[0.0,0.0,1.0,1.0,5.0,5.0,6.0,6.0]}'
        geom2 = '{"_coords":[0.0,0.0,1.0,1.0]}'
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

    def test_invalid_json_fails_batch(self):
        """Test handler with invalid JSON fails batch (FAIL_FAST mode)"""
        event = {"arguments": [["not valid json", 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        # With FAIL_FAST (default), invalid JSON fails the batch
        assert result["success"] is False
        assert "Error processing row 0" in result["error_msg"]
