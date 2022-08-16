### st_intersects
`Boolean st_intersects(Geometry a, Geometry b)`

Returns `true` if the geometries spatially intersect in 2D (i.e. share any portion of space). Equivalent to `NOT st_disjoint(a, b)`.