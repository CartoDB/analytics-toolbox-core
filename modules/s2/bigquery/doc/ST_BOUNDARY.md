### ST_BOUNDARY

{{% bannerNote type="code" %}}
s2.ST_BOUNDARY(id)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given S2 cell ID. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it into geography.

* `id`: `BIGNUMERIC` S2 cell ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT bqcarto.s2.ST_BOUNDARY(1735346007979327488);
-- POLYGON((40.6346851320784 -3.8440544113597, 40.6346851320784 ...
```
