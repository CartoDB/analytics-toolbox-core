### LONGLAT_ASTOKEN

{{% bannerNote type="code" %}}
s2.LONGLAT_ASTOKEN(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID for a given longitude, latitude and zoom resolution.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`STRING` * S2 cell hexified ID.

**Example**

TO DO