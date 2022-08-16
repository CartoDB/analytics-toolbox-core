### st_lengthSphere
`Double st_lengthSphere(LineString line)`

Approximates the 2D path length of a `LineString` geometry using a spherical earth model. The returned length is in units of meters. The approximation is within 0.3% of st_lengthSpheroid and is computationally more efficient.