### st_disjoint
`Boolean st_disjoint(Geometry a, Geometry b)`

Returns `true` if the geometries do not “spatially intersect”; i.e., they do not share any space together. Equivalent to `NOT st_intersects(a, b)`.