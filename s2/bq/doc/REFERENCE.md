## Reference

### S2

#### VERSION

{{% bannerNote type="code" %}}
s2.VERSION()
{{%/ bannerNote %}}

Returns the current version of the s2 library.

#### ID_FROMKEY

{{% bannerNote type="code" %}}
s2.ID_FROMKEY(key STRING)
{{%/ bannerNote %}}

Convert from hilbert quadtree id to s2 cell id.

* `key`: `STRING` quadkey to be converted.

#### ID_FROMLONGLAT

{{% bannerNote type="code" %}}
s2.ID_FROMLONGLAT(longitude FLOAT64, latitude FLOAT64, level INT64)
{{%/ bannerNote %}}

Generate the s2 cell id for a given longitude, latitude and zoom level.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `INT64` Level of detail or zoom.

#### KEY_FROMID

{{% bannerNote type="code" %}}
s2.KEY_FROMID(id INT64)
{{%/ bannerNote %}}

Convert from s2 cell id to hilbert quadtree id.

* `id`: `INT64` s2 cell id to be converted.

#### KEY_FROMLONGLAT

{{% bannerNote type="code" %}}
s2.KEY_FROMLONGLAT(longitude FLOAT64, latitude FLOAT64, level INT64)
{{%/ bannerNote %}}

Generate the quadkey for a given longitude, latitude and zoom level.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `INT64` Level of detail or zoom.

#### LONG_FROMID

{{% bannerNote type="code" %}}
s2.LONG_FROMID(id INT64)
{{%/ bannerNote %}}

Extract the longitude component from the centroid of a given s2 cell id.

* `id`: `INT64` s2 cell id.

#### LONG_FROMKEY

{{% bannerNote type="code" %}}
s2.LONG_FROMKEY(key STRING)
{{%/ bannerNote %}}

Extract the longitude component from a quadkey.

* `key`: `STRING` quadkey.

#### LAT_FROMID

{{% bannerNote type="code" %}}
s2.LAT_FROMID(id INT64)
{{%/ bannerNote %}}

Extract the latitude component from the centroid of a given s2 cell id.

* `id`: `INT64` s2 cell id.

#### LAT_FROMKEY

{{% bannerNote type="code" %}}
s2.LAT_FROMKEY(key STRING)
{{%/ bannerNote %}}

Extract the latitude component from a quadkey.

* `key`: `STRING` quadkey.

#### LONGLAT_ASS2

{{% bannerNote type="code" %}}
s2.LONGLAT_ASS2(longitude FLOAT64, latitude FLOAT64, resolution INT64)
{{%/ bannerNote %}}

Returns the s2 representation for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `INT64` Level of detail or zoom.

#### ST_ASS2

{{% bannerNote type="code" %}}
s2.ST_ASS2(point GEOGRAPHY, resolution INT64)
{{%/ bannerNote %}}

Converts a given point at given level of detail to a s2 cell id.

* `point`: `GEOGRAPHY` point we want to get the quadint from.
* `level`: `INT64` Level of detail or zoom.

#### ST_GEOGFROMKEY_BOUNDARY

{{% bannerNote type="code" %}}
s2.ST_GEOGFROMKEY_BOUNDARY(key STRING)
{{%/ bannerNote %}}

Returns the geography boundary for a given quadkey. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it to geography.

* `key`: `STRING` quadkey we want to get the boundary geography from.