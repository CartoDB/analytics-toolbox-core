## Reference

### S2

#### s2.VERSION

{{% bannerNote type="code" %}}
s2.VERSION() -> INT64
{{%/ bannerNote %}}

Returns the current version of the s2 library.

#### s2.ID_FROMKEY

{{% bannerNote type="code" %}}
s2.ID_FROMKEY(key STRING) -> INT64
{{%/ bannerNote %}}

* `key`: `STRING` quadkey to be converted.

Convert from hilbert quadtree id to s2 cell id.

#### s2.ID_FROMLONGLAT

{{% bannerNote type="code" %}}
s2.ID_FROMLONGLAT(longitude FLOAT64, latitude FLOAT64, level INT64) -> INT64
{{%/ bannerNote %}}

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `INT64` Level of detail or zoom.

Generate the s2 cell id for a given longitude, latitude and zoom level.

#### s2.KEY_FROMID

{{% bannerNote type="code" %}}
s2.KEY_FROMID(id INT64) -> STRING
{{%/ bannerNote %}}

* `id`: `INT64` s2 cell id to be converted.

Convert from s2 cell id to hilbert quadtree id.

#### s2.LONG_FROMID

{{% bannerNote type="code" %}}
s2.LONG_FROMID(id INT64) -> FLOAT64
{{%/ bannerNote %}}

* `id`: `INT64` s2 cell id.

Extract the longitude component from the centroid of a given s2 cell id.

#### s2.LAT_FROMID

{{% bannerNote type="code" %}}
s2.LAT_FROMID(id INT64) -> FLOAT64
{{%/ bannerNote %}}

* `id`: `INT64` s2 cell id.

Extract the latitude component from the centroid of a given s2 cell id.

#### s2.LONGLAT_ASS2

{{% bannerNote type="code" %}}
s2.LONGLAT_ASS2(longitude FLOAT64, latitude FLOAT64, resolution INT64) -> STRING
{{%/ bannerNote %}}

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `INT64` Level of detail or zoom.

Returns the s2 representation for a given level of detail and geographic coordinates.

#### s2.ST_ASS2

{{% bannerNote type="code" %}}
s2.ST_ASS2(point GEOGRAPHY, resolution INT64) -> STRING
{{%/ bannerNote %}}

* `point`: `GEOGRAPHY` point we want to get the quadint from.
* `level`: `INT64` Level of detail or zoom.

Converts a given point at given level of detail to a s2 cell id.

#### s2.ST_GEOGFROMKEY_BOUNDARY

{{% bannerNote type="code" %}}
s2.ST_GEOGFROMKEY_BOUNDARY(key STRING) -> GEOGRAPHY
{{%/ bannerNote %}}

* `key`: `STRING` quadkey we want to get the boundary geography from.

Returns the geography boundary for a given quadkey. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it to geography.