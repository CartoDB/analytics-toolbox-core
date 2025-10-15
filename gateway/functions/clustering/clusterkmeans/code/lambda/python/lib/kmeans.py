# Copyright (c) 2020, Avi Arora (Python implementation)
# (https://analyticsarora.com/k-means-for-beginners-how-to-build-from-scratch-in-python/)
# Copyright (c) 2021, CARTO (lint, minor fixes)

import numpy as np


# Set random seed so output is all same
np.random.seed(1)


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
