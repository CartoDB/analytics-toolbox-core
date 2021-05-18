### DISTANCE

{{% bannerNote type="code" %}}
h3.DISTANCE(origin, destination)
{{%/ bannerNote %}}

**Description**

Returns the **grid distance** between two hexagon indexes. This function may fail to find the distance between two indexes if they are very far apart or on opposite sides of a pentagon. Returns `null` on failure or invalid input.

* `origin`: `STRING` The H3 cell index as hexadecimal.
* `destination`: `STRING` The H3 cell index as hexadecimal.

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.h3.DISTANCE('847b591ffffffff', '847b59bffffffff');
-- 1
```

{{% bannerNote type="note" title="tip"%}}
If you want the distance in meters use [ST_DISTANCE](https://docs.snowflake.com/en/sql-reference/functions/st_distance.html) between the cells ([ST_BOUNDARY](#st_boundary)) or their centroid.
{{%/ bannerNote %}}