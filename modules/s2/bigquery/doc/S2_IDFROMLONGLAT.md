### S2_IDFROMLONGLAT

{{% bannerNote type="code" %}}
s2.S2_IDFROMLONGLAT(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID for a given longitude, latitude and zoom resolution.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.s2.S2_IDFROMLONGLAT(-3.7038, 40.4168, 8);
-- 955378847514099712
```