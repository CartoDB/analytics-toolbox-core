### st_antimeridianSafeGeom
`Geometry st_antimeridianSafeGeom(Geometry geom)`

If _geom_ spans the [antimeridian](https://en.wikipedia.org/wiki/180th_meridian), attempt to convert the `Geometry` into an equivalent form that is “antimeridian-safe” (i.e. the output `Geometry` is covered by `BOX(-180 -90, 180 90)`). In certain circumstances, this method may fail, in which case the input `Geometry` will be returned and an error will be logged.
