# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from math import floor, sqrt


class Spline:
    """Bezier spline curve generator."""

    def __init__(self, points_data=[], resolution=10000, sharpness=0.85):
        self.duration = resolution
        self.sharpness = sharpness
        self.centers = []
        self.controls = []
        self.stepLength = 60
        self.delay = 0
        self.steps = []
        self.points = points_data
        self.length = len(self.points)

        # Initialize z coordinate if missing
        for i in range(0, self.length):
            if "z" not in self.points[i]:
                self.points[i]["z"] = 0

        # Calculate centers between points
        for i in range(0, self.length - 1):
            p1 = self.points[i]
            p2 = self.points[i + 1]
            self.centers.append(
                {
                    "x": (p1["x"] + p2["x"]) / 2,
                    "y": (p1["y"] + p2["y"]) / 2,
                    "z": (p1["z"] + p2["z"]) / 2,
                }
            )

        # Initialize control points
        self.controls.append([self.points[0], self.points[0]])

        # Calculate control points for spline
        for i in range(0, len(self.centers) - 1):
            dx = (
                self.points[i + 1]["x"]
                - (self.centers[i]["x"] + self.centers[i + 1]["x"]) / 2
            )
            dy = (
                self.points[i + 1]["y"]
                - (self.centers[i]["y"] + self.centers[i + 1]["y"]) / 2
            )
            dz = (
                self.points[i + 1]["z"]
                - (self.centers[i]["z"] + self.centers[i + 1]["z"]) / 2
            )
            self.controls.append(
                [
                    {
                        "x": (1.0 - self.sharpness) * self.points[i + 1]["x"]
                        + self.sharpness * (self.centers[i]["x"] + dx),
                        "y": (1.0 - self.sharpness) * self.points[i + 1]["y"]
                        + self.sharpness * (self.centers[i]["y"] + dy),
                        "z": (1.0 - self.sharpness) * self.points[i + 1]["z"]
                        + self.sharpness * (self.centers[i]["z"] + dz),
                    },
                    {
                        "x": (1.0 - self.sharpness) * self.points[i + 1]["x"]
                        + self.sharpness * (self.centers[i + 1]["x"] + dx),
                        "y": (1.0 - self.sharpness) * self.points[i + 1]["y"]
                        + self.sharpness * (self.centers[i + 1]["y"] + dy),
                        "z": (1.0 - self.sharpness) * self.points[i + 1]["z"]
                        + self.sharpness * (self.centers[i + 1]["z"] + dz),
                    },
                ]
            )

        self.controls.append(
            [self.points[self.length - 1], self.points[self.length - 1]]
        )
        self.steps = self.cache_steps(self.stepLength)

    def cache_steps(self, mindist):
        """Cache steps for efficient distance calculations."""
        steps = []
        laststep = self.pos(0)
        steps.append(0)
        t = 0
        while t < self.duration:
            step = self.pos(t)
            dist = sqrt(
                (step["x"] - laststep["x"]) * (step["x"] - laststep["x"])
                + (step["y"] - laststep["y"]) * (step["y"] - laststep["y"])
                + (step["z"] - laststep["z"]) * (step["z"] - laststep["z"])
            )

            if dist > mindist:
                steps.append(t)
                laststep = step

            t += 10

        return steps

    def pos(self, time):
        """Get position on spline at given time."""
        t = time - self.delay
        if t < 0:
            t = 0
        if t > self.duration:
            t = self.duration - 1

        t2 = t / self.duration

        if t2 >= 1:
            return self.points[self.length - 1]

        n = int(floor((len(self.points) - 1) * t2))
        t1 = (self.length - 1) * t2 - n

        return self.bezier(
            t1,
            self.points[n],
            self.controls[n][1],
            self.controls[n + 1][0],
            self.points[n + 1],
        )

    def bezier(self, t, p1, c1, c2, p2):
        """Calculate bezier curve point."""
        b = self.b(t)
        pos = {
            "x": p2["x"] * b[0] + c2["x"] * b[1] + c1["x"] * b[2] + p1["x"] * b[3],
            "y": p2["y"] * b[0] + c2["y"] * b[1] + c1["y"] * b[2] + p1["y"] * b[3],
            "z": p2["z"] * b[0] + c2["z"] * b[1] + c1["z"] * b[2] + p1["z"] * b[3],
        }
        return pos

    def b(self, t):
        """Calculate bezier basis functions."""
        t2 = t * t
        t3 = t2 * t
        return [
            t3,
            (3 * t2 * (1 - t)),
            (3 * t * (1 - t) * (1 - t)),
            ((1 - t) * (1 - t) * (1 - t)),
        ]
