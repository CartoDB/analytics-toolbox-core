### st_length
`Double st_length(Geometry geom)`

Returns the 2D path length of linear geometries, or perimeter of areal geometries, in units of the the coordinate reference system (e.g. degrees for EPSG:4236). Returns `0.0` for other geometry types (e.g. `Point`).