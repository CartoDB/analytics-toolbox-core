## Reference

### PLACEKEY

#### VERSION

{{% bannerNote type="code" %}}
placekey.VERSION()
{{%/ bannerNote %}}

Returns the current version of the placekey library.

#### PLACEKEY_FROMH3

{{% bannerNote type="code" %}}
placekey.PLACEKEY_FROMH3(h3Index STRING)
{{%/ bannerNote %}}

Transform a h3 index to an equivalent placekey.

* `h3Index`: `STRING` h3 index we want to convert to placekey.

#### H3_FROMPLACEKEY

{{% bannerNote type="code" %}}
placekey.H3_FROMPLACEKEY(placekey STRING)
{{%/ bannerNote %}}

Transform a placekey to an equivalent h3 index.

* `placekey`: `STRING` placekey we want to convert to h3.

#### LONGLAT_FROMPLACEKEY

{{% bannerNote type="code" %}}
placekey.LONGLAT_FROMPLACEKEY(placekey STRING)
{{%/ bannerNote %}}

Return the geographic coordinates corresponding to a given placekey. The return format is a STRING containing the longitude and llatitude separated by a comma.

* `placekey`: `STRING` placekey we want to extract the coordinates from.

#### LONGLAT_ASPLACEKEY

{{% bannerNote type="code" %}}
placekey.LONGLAT_ASPLACEKEY(longitude FLOAT64, latitude FLOAT64)
{{%/ bannerNote %}}

Returns the placekey representation for given geographic coordinates.

* `longitude`: `FLOAT64` horizontal coordinate of the map.
* `latitude`: `FLOAT64` vertical coordinate of the map.

#### ST_ASPLACEKEY

{{% bannerNote type="code" %}}
placekey.ST_ASPLACEKEY(point GEOGRAPHY)
{{%/ bannerNote %}}

Convert a given point to a placekey.

* `point`: `GEOGRAPHY`  point we want to get the placekey from.

#### ST_GEOGFROMPLACEKEY_POINT

{{% bannerNote type="code" %}}
placekey.ST_GEOGFROMPLACEKEY_POINT(placekey STRING)
{{%/ bannerNote %}}

Return the geography point equivalent of a placekey.

* `placekey`: `STRING` placekey we want to get the point from.