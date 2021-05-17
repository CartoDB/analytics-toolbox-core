### ST_BOUNDARY

{{% bannerNote type="code" %}}
s2.ST_BOUNDARY_FROMTOKEN(id)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given S2 cell ID. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it into geography.

* `token`: `STRING` S2 cell hexified ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

TO DO