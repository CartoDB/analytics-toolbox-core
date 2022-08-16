### st_interiorRingN
`Int st_interiorRingN(Geometry geom, Int n)`

Returns the _n_-th interior `LineString` ring of the `Polygon` _geom_. Returns null if the `Geometry` is not a `Polygon` or the given _n_ is out of range.