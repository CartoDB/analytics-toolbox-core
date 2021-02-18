## Reference

### S2

#### VERSION

{{% bannerNote type="code" %}}
s2.VERSION()
{{%/ bannerNote %}}

Returns the current version of the s2 library.

#### GEOJSONBOUNDARY_FROMKEY

{{% bannerNote type="code" %}}
s2.GEOJSONBOUNDARY_FROMKEY(key STRING) 
{{%/ bannerNote %}}

Returns a GeoJSON containing the boundary corners of a quadkey.

* `key`: `STRING` quadkey to extract the corners from.

#### GEOJSONBOUNDARY_FROMLONGLAT

{{% bannerNote type="code" %}}
s2.GEOJSONBOUNDARY_FROMLONGLAT(longitude FLOAT64, latitude FLOAT64, level NUMERIC)
{{%/ bannerNote %}}

Returns a GeoJSON containing the boundary corners given a longitud, latitud and zoom level.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `NUMERIC` Level of detail or zoom.

#### ID_FROMKEY

{{% bannerNote type="code" %}}
s2.ID_FROMKEY(key STRING)
{{%/ bannerNote %}}

Convert from hilbert quadtree id to s2 cell id.

* `key`: `STRING` quadkey to be converted.

#### ID_FROMLONGLAT

{{% bannerNote type="code" %}}
s2.ID_FROMLONGLAT(longitude FLOAT64, latitude FLOAT64, level NUMERIC)
{{%/ bannerNote %}}

Generate the s2 cell id for a given longitud, latitud and zoom level.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `NUMERIC` Level of detail or zoom.

#### KEY_FROMID

{{% bannerNote type="code" %}}
s2.KEY_FROMID(id INT64)
{{%/ bannerNote %}}

Convert from s2 cell id to hilbert quadtree id.

* `id`: `INT64` s2 cell id to be converted.

#### KEY_FROMLONGLAT

{{% bannerNote type="code" %}}
s2.KEY_FROMLONGLAT(longitude FLOAT64, latitude FLOAT64, level NUMERIC)
{{%/ bannerNote %}}

Generate the quadkey for a given longitud, latitud and zoom level.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `NUMERIC` Level of detail or zoom.

#### LONG_FROMID

{{% bannerNote type="code" %}}
s2.LONG_FROMID(id INT64)
{{%/ bannerNote %}}

Extract the longitude component from a give s2 cell id.

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

Extract the latitude component from a give s2 cell id.

* `id`: `INT64` s2 cell id.

#### LAT_FROMKEY

{{% bannerNote type="code" %}}
s2.LAT_FROMKEY(key STRING)
{{%/ bannerNote %}}

Extract the latitude component from a quadkey.

* `key`: `STRING` quadkey.

#### LONGLAT_ASS2

{{% bannerNote type="code" %}}
s2.LONGLAT_ASS2(longitude FLOAT64, latitude FLOAT64, resolution NUMERIC)
{{%/ bannerNote %}}

Returns the s2 representation for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `NUMERIC` Level of detail or zoom.

#### ST_ASS2

{{% bannerNote type="code" %}}
s2.ST_ASS2(point GEOGRAPHY, resolution NUMERIC)
{{%/ bannerNote %}}

Converts a given point at given level of detail to a s2 cell id.

* `point`: `GEOGRAPHY` point we want to get the quadint from.
* `level`: `NUMERIC` Level of detail or zoom.

#### ST_GEOGFROMLATLNG_BOUNDARY

{{% bannerNote type="code" %}}
s2.ST_GEOGFROMLATLNG_BOUNDARY(latitude FLOAT64, longitude FLOAT64, level NUMERIC)
{{%/ bannerNote %}}

Returns the geography boundary for a given level of detail and geographic coordinates. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GEOJSON and finally transform it to geography.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `level`: `NUMERIC` Level of detail or zoom.

#### ST_GEOGFROMS2_BOUNDARY

{{% bannerNote type="code" %}}
s2.ST_GEOGFROMS2_BOUNDARY(key STRING)
{{%/ bannerNote %}}

Returns the geography boundary for a given quadkey. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GEOJSON and finally transform it to geography.

* `key`: `STRING` quadkey we want to get the boundary geography from.