### QUADINT_FROMLONGLAT

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROMLONGLAT(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadint representation for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT8` horizontal coordinate of the map.
* `latitude`: `FLOAT8` vertical coordinate of the map.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT quadkey.QUADINT_FROMLONGLAT(40.4168, -3.7038, 4);
-- 4388
```