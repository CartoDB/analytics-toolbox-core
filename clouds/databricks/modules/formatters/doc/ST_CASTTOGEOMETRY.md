### st_castToGeometry
`Geometry st_castToGeometry(Geometry g)`

Casts `Geometry` subclass _g_ to a `Geometry`. This can be necessary e.g. when storing the output of `st_makePoint` as a `Geometry` in a case class.