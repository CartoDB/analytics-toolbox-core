### S2_IDFROMGEOGPOINT

{{% bannerNote type="code" %}}
carto.S2_IDFROMGEOGPOINT(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the ID from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.S2_IDFROMGEOGPOINT(ST_GEOGPOINT(40.4168, -3.7038), 8);
-- 1735346007979327488
```