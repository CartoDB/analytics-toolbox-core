### LONGLAT_ASID

{{% bannerNote type="code" %}}
s2.LONGLAT_ASID(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadint representation for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT` horizontal coordinate of the map.
* `latitude`: `FLOAT` vertical coordinate of the map.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`VARCHAR`

**Example**

```sql
SELECT s2.LONGLAT_ASID(40.4168, -3.7038, 4);
-- 1733885856537640960
```