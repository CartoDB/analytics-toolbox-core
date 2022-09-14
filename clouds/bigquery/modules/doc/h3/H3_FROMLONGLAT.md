### H3_FROMLONGLAT

{{% bannerNote type="code" %}}
carto.H3_FROMLONGLAT(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index that the point belongs to in the required `resolution`. It will return `null` on error (resolution out of bounds).

* `longitude`: `FLOAT64` horizontal coordinate of the map.
* `latitude`: `FLOAT64` vertical coordinate of the map.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.H3_FROMLONGLAT(40.4168, -3.7038, 4);
-- 847b59dffffffff
```