### st_isClosed
`Boolean st_isClosed(Geometry geom)`

Returns `true` if geom is a `LineString` or `MultiLineString` and its start and end points are coincident. Returns true for all other `Geometry` types.