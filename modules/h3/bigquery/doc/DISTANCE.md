### DISTANCE

{{% bannerNote type="code" %}}
h3.DISTANCE(origin, destination)
{{%/ bannerNote %}}

**Description**

Returns the **grid distance** between two hexagon indexes. This function may fail to find the distance between two indexes if they are very far apart or on opposite sides of a pentagon. Returns `null` on failure or invalid input.

* `origin`: `STRING` origin H3 cell index.
* `destination`: `STRING` destination H3 cell index.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.h3.DISTANCE('847b591ffffffff', '847b59bffffffff');
-- 1
```

{{% bannerNote type="note" title="tip"%}}
If you want the distance in meters use [ST_DISTANCE](https://cloud.google.com/bigquery/docs/reference/standard-sql/geography_functions#st_distance) between the cells ([ST_BOUNDARY](#st_boundary)) or their centroid.
{{%/ bannerNote %}}