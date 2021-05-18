### LONGLAT_ASH3

{{% bannerNote type="code" %}}
h3.LONGLAT_ASH3(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index that the point belongs to in the required `resolution`. It will return `null` on error (resolution out of bounds).

* `longitude`: `DOUBLE` horizontal coordinate of the map.
* `latitude`: `DOUBLE` vertical coordinate of the map.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

**Example**

```sql
SELECT sfcarto.h3.LONGLAT_ASH3(40.4168, -3.7038, 4);
-- 847b59dffffffff
```