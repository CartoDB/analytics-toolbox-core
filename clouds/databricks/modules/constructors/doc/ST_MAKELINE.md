### ST_MAKELINE

{{% bannerNote type="code" %}}
carto.ST_MAKELINE(points)
{{%/ bannerNote %}}

**Description**

Creates a `LineString` using the given sequence of vertices in points.

* `points`: `Seq[Point]` input sequence of points for the line.

**Return type**

`LineString`

**Example**

```sql
select ST_MAKELINE(ST_MAKEPOINT(-93.477736, 33.642527), ST_MAKEPOINT(-93.47825, 33.642768))
-- NOT WORKING!
```
