# Copyright (c) 2020, Avi Arora (Python implementation)
# (https://analyticsarora.com/k-means-for-beginners-how-to-build-from-scratch-in-python/)
# Copyright (c) 2021, CARTO (lint, minor fixes)
# Copyright (c) 2025, CARTO (Lambda adaptation)

"""
CARTO Analytics Toolbox - CLUSTERKMEANSTABLE
Lambda handler for Redshift external function

This function performs K-means clustering on coordinates from a table geometry format.
Returns JSON array with cluster assignments and indices.
"""

import json
import numpy as np

# Import lambda wrapper
# In Lambda: packaged as carto_analytics_toolbox_core
# In local tests: conftest.py sets up the module alias
from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler

# Set random seed for consistent results
np.random.seed(1)

PRECISION = 15


class KMeans(object):
    """KMeans class."""

    def __init__(self):
        pass

    def pairwise_dist(self, x, y):
        """pairwise_dist.

        Parameters
        ----------
        x: n x d numpy array
        y: M x d numpy array

        Returns
        -------
        dist: n x M array, where dist2[i, j] is the euclidean distance between
        x[i, :] and y[j, :]
        """
        x_sum_square = np.sum(np.square(x), axis=1)
        y_sum_square = np.sum(np.square(y), axis=1)
        mul = np.dot(x, y.T)
        dists = np.sqrt(abs(x_sum_square[:, np.newaxis] + y_sum_square - 2 * mul))
        return dists

    def _init_centers(self, points, k, **kwargs):
        """_init_centers.

        Parameters
        ----------
        points: NxD numpy array, where n is # points and d is the dimensionality
        k: number of clusters
        kwargs: any additional arguments you want

        Returns
        -------
        centers: k x d numpy array, the centers.
        """
        row, col = points.shape
        ret_arr = np.empty([k, col])
        for number in range(k):
            rand_index = np.random.randint(row)
            ret_arr[number] = points[rand_index]

        return ret_arr

    def _update_assignment(self, centers, points):
        """_update_assignment.

        Parameters
        ----------
        centers: KxD numpy array, where k is the number of clusters,
        and d is the dimension
        points: NxD numpy array, the observations

        Returns
        -------
        cluster_idx: numpy array of length n, the cluster assignment for each point

        Hint: You could call pairwise_dist() function.
        """
        row, col = points.shape
        cluster_idx = np.empty([row])
        distances = self.pairwise_dist(points, centers)
        cluster_idx = np.argmin(distances, axis=1)

        return cluster_idx

    def _update_centers(self, old_centers, cluster_idx, points):
        """_update_centers.

        Parameters
        ----------
        old_centers: old centers KxD numpy array, where k is the number of clusters,
        and d is the dimension
        cluster_idx: numpy array of length n, the cluster assignment for each point
        points: NxD numpy array, the observations

        Returns
        -------
        centers: new centers, k x d numpy array, where k is the number of clusters,
        and d is the dimension.
        """
        k, d = old_centers.shape
        new_centers = np.empty(old_centers.shape)
        for i in range(k):
            new_centers[i] = np.mean(points[cluster_idx == i], axis=0)
        return new_centers

    def _get_loss(self, centers, cluster_idx, points):
        """_get_loss.

        Parameters
        ----------
        centers: KxD numpy array, where k is the number of clusters,
        and d is the dimension
        cluster_idx: numpy array of length n, the cluster assignment for each point
        points: NxD numpy array, the observations

        Returns
        -------
            loss: a single float number, which is the objective function of KMeans.
        """
        dists = self.pairwise_dist(points, centers)
        loss = 0.0
        n, d = points.shape
        for i in range(n):
            loss = loss + np.square(dists[i][cluster_idx[i]])

        return loss

    def __call__(
        self,
        points,
        k,
        max_iters=10000,
        abs_tol=1e-16,
        rel_tol=1e-16,
        verbose=False,
        **kwargs,
    ):
        """call.

        Parameters
        ----------
        points: NxD numpy array, where n is # points and d is the dimensionality
        k: number of clusters
        max_iters: maximum number of iterations
        (Hint: You could change it when debugging)
        abs_tol: convergence criteria w.r.t absolute change of loss
        rel_tol: convergence criteria w.r.t relative change of loss
        verbose: boolean to set whether method should print loss
        (Hint: helpful for debugging)
        kwargs: any additional arguments you want

        Returns
        -------
        cluster assignments: Nx1 int numpy array
        cluster centers: k x d numpy array, the centers
        loss: final loss value of the objective function of KMeans
        """
        # centers = self._init_centers(points, k, **kwargs)
        # instead of using random initialization, we will use the first k points
        centers = points[:k]
        prev_loss = 0
        for it in range(max_iters):
            cluster_idx = self._update_assignment(centers, points)
            centers = self._update_centers(centers, cluster_idx, points)
            loss = self._get_loss(centers, cluster_idx, points)
            k = centers.shape[0]
            if it:
                diff = np.abs(prev_loss - loss)
                if diff < abs_tol and diff / prev_loss < rel_tol:
                    break
            prev_loss = loss
            if verbose:
                print("iter %d, loss: %.4f" % (it, loss))
        return cluster_idx, centers, loss


def reorder_coords(coords):
    """
    Reorder coordinates to place unique coordinates first, then duplicates.

    Args:
        coords: numpy array of coordinates

    Returns:
        Reordered numpy array
    """
    unique_coords = []
    duplicated_coords = []

    # Split the array into unique and duplicated coordinates
    count_map = {}
    for coord in coords:
        coord_str = tuple(coord)
        if coord_str not in count_map:
            count_map[coord_str] = 1
            unique_coords.append(coord)
        else:
            count_map[coord_str] += 1
            duplicated_coords.append(coord)

    # Convert lists to NumPy arrays
    unique_coords = np.array(unique_coords)
    duplicated_coords = (
        np.array(duplicated_coords) if duplicated_coords else np.array([])
    )

    if unique_coords.size > 0:
        if duplicated_coords.size > 0:
            return np.concatenate((unique_coords, duplicated_coords))
        else:
            return unique_coords
    else:
        if duplicated_coords.size > 0:
            return duplicated_coords
        else:
            return coords


def count_distinct_coords(coords):
    """
    Count distinct coordinates in array.

    Args:
        coords: numpy array of coordinates

    Returns:
        Number of distinct coordinates
    """
    count_map = {}
    for coord in coords:
        coord_str = tuple(coord)
        count_map[coord_str] = count_map.get(coord_str, 0) + 1
    return len(count_map)


def clusterkmeanstable(geom_json, k):
    """
    Perform K-means clustering on table geometry coordinates.

    Args:
        geom_json: JSON string with _coords array (flat list of x,y pairs)
        k: number of clusters

    Returns:
        JSON string with cluster assignments: [{"c": cluster_id, "i": index}, ...]
    """
    # Parse geometry
    geom = json.loads(geom_json)
    points = geom["_coords"]

    # Convert flat coordinate array to Nx2 array
    coords = reorder_coords(
        np.array([[points[i], points[i + 1]] for i in range(0, len(points) - 1, 2)])
    )

    # k cannot be greater than the number of distinct coordinates
    k = min(k, count_distinct_coords(coords))

    # Run K-means
    cluster_idxs, centers, loss = KMeans()(coords, k)

    # Return cluster assignments with 1-based indices
    return json.dumps(
        [
            {"c": int(cluster_idxs[idx]), "i": idx + 1}
            for idx, point in enumerate(coords)
        ]
    )


@redshift_handler
def process_clusterkmeanstable_row(row):
    """
    Process a single clustering request row for table geometry format.

    Args:
        row: List containing [geometry_json, k] where:
            - geometry_json: JSON string with _coords array (flat list of x,y pairs)
            - k: number of clusters

    Returns:
        JSON string with cluster assignments and indices, or None for invalid inputs
    """
    # Handle invalid row structure
    if row is None or len(row) < 2:
        return None

    geom, k = row[0], row[1]

    # Handle null inputs
    if geom is None or k is None:
        return None

    # Process the clustering
    result_json = clusterkmeanstable(str(geom), int(k))
    return result_json


# Export as lambda_handler for AWS Lambda
lambda_handler = process_clusterkmeanstable_row
