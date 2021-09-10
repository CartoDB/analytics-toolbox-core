### LONGLAT_ASQUADINT

{{% bannerNote type="code" %}}
quadkey.LONGLAT_ASQUADINT(longitude, latitude, resolution)
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
SELECT quadkey.LONGLAT_ASQUADINT(40.4168, -3.7038, 4);
-- 4388
```