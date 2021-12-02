### GEOHASH_BOUNDARY

{{% bannerNote type="code" %}}
carto.GEOHASH_BOUNDARY(index)
{{%/ bannerNote %}}

**Description**

Returns a geography representing the geohash cell. It will return `null` on error (invalid input).

* `index`: `STRING` The Geohash cell index. The maximum length supported is 17.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.GEOHASH_BOUNDARY('ezrqcjzgdr3');
-- POLYGON((-1.00000128149986 41.9999988377094, -0.999999940395355 41.9999988377094, ...
```
