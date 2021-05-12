### LONGLAT_ASID

{{% bannerNote type="code" %}}
s2.LONGLAT_ASID(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID for a given longitude, latitude and zoom resolution.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`BIGNUMERIC`

**Example**

```sql
SELECT bqcarto.s2.LONGLAT_ASID(-3.7038, 40.4168, 8);
-- 955378847514099712
```
