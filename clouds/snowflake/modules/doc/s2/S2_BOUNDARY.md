### S2_BOUNDARY

{{% bannerNote type="code" %}}
carto.S2_BOUNDARY(id)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given S2 cell ID. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it into geography.

* `id`: `BIGINT` S2 cell ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.S2_BOUNDARY(1735346007979327488);
-- { "coordinates": [ [ [ 40.30886257091771, -3.8626948530725476 ], [ 40.30886257091771, -3.6086596856604585 ] ...
```

{{% bannerNote title="tip"%}}
S2 Cell edges are spherical geodesics.
{{%/ bannerNote %}}
