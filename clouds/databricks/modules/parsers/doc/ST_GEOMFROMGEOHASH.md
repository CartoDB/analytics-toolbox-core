### st_geomFromGeoHash
`Geometry st_geomFromGeoHash(String geohash, Int prec)`

Returns the `Geometry` of the bounding box corresponding to the Geohash string _geohash_ (base-32 encoded) with a precision of prec bits. See [Geohash](https://www.geomesa.org/documentation/stable/user/appendix/utils.html#geohash) for more information on GeoHashes.