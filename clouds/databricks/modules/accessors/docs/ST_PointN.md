### st_pointN
`Point st_pointN(Geometry geom, Int n)`

If _geom_ is a `LineString`, returns the _n_-th vertex of _geom_ as a `Point`. Negative values are counted backwards from the end of the `LineString`. Returns `null` if _geom_ is not a `LineString`.