## Reference

### S2

Our S2 module, is based on a port of the original s2 geometry created by Google. Check this [website] (http://s2geometry.io/) for more information about S2.

#### s2.VERSION

{{% bannerNote type="code" %}}
s2.VERSION() -> INT64
{{%/ bannerNote %}}

Returns the current version of the s2 library.

#### s2.ID_FROMHILBERTQUADKEY

{{% bannerNote type="code" %}}
s2.ID_FROMHILBERTQUADKEY(quadkey STRING) -> INT64
{{%/ bannerNote %}}

* `quadkey`: `STRING` quadkey to be converted.

Convert from hilbert quadtree id to s2 cell id.

#### s2.HILBERTQUADKEY_FROMID

{{% bannerNote type="code" %}}
s2.HILBERTQUADKEY_FROMID(id INT64) -> STRING
{{%/ bannerNote %}}

* `id`: `INT64` s2 cell id to be converted.

Convert from s2 cell id to hilbert quadtree id.

#### s2.LONGLAT_ASID

{{% bannerNote type="code" %}}
s2.LONGLAT_ASID(longitude FLOAT64, latitude FLOAT64, level INT64) -> INT64
{{%/ bannerNote %}}

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `INT64` Level of detail or zoom.

Generate the s2 cell id for a given longitude, latitude and zoom level.

#### s2.ST_ASID

{{% bannerNote type="code" %}}
s2.ST_ASID(point GEOGRAPHY, resolution INT64) -> INT64
{{%/ bannerNote %}}

* `point`: `GEOGRAPHY` point we want to get the quadint from.
* `level`: `INT64` Level of detail or zoom.

Converts a given point at given level of detail to a s2 cell id.

#### s2.ST_GEOGFROMID_BOUNDARY

{{% bannerNote type="code" %}}
s2.ST_GEOGFROMID_BOUNDARY(id INT64) -> GEOGRAPHY
{{%/ bannerNote %}}

* `id`: `INT64` s2 cell id we want to get the boundary geography from.

Returns the geography boundary for a given s2 cell id. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it to geography.