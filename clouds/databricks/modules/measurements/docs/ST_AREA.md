### st_area
`Double st_area(Geometry g)`

If `Geometry` _g_ is areal, returns the area of its surface in square units of the coordinate reference system (for example, `degrees^2` for EPSG:4326). Returns `0.0` for non-areal geometries (e.g. `Points`, non-closed `LineStrings`, etc.).