### ST_BOUNDARY

{{% bannerNote type="code" %}}
geohash.ST_BOUNDARY(index)
{{%/ bannerNote %}}

**Description**

Returns a geography representing the geohash cell.

* `index`: `STRING` The Geohash cell index.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.geohash.ST_BOUNDARY('ezrqcjzgdr3');
-- POLYGON((-1.00000128149986 41.9999988377094, -0.999999940395355 41.9999988377094, ...
```
