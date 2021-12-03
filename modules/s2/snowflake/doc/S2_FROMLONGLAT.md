### S2_FROMLONGLAT

{{% bannerNote type="code" %}}
carto.S2_FROMLONGLAT(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID for a given longitude, latitude and zoom resolution.

* `longitude`: `DOUBLE` horizontal coordinate on the map.
* `latitude`: `DOUBLE` vertical coordinate on the map.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.S2_FROMLONGLAT(40.4168, -3.7038, 8);
-- 1735346007979327488
```