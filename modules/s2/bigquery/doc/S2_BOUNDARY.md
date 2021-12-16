### S2_BOUNDARY

{{% bannerNote type="code" %}}
carto.S2_BOUNDARY(id)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given S2 cell ID. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it into geography.

* `id`: `INT64` S2 cell ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.S2_BOUNDARY(1735346007979327488);
-- POLYGON((40.6346851320784 -3.8440544113597, 40.6346851320784 ...
```

{{% bannerNote title="tip"%}}
S2 Cell edges are spherical geodesics. The boundary edges can be interpreted as straight lines in other GIS tools, so to export the exact shape of the cells, use `ST_GEOGFROM(ST_ASGEOJSON(geog)`. In this process, BigQuery will add intermediate points to preserve the geodesic curves.
{{%/ bannerNote %}}