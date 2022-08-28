### ST_MAKEBBOX

{{% bannerNote type="code" %}}
carto.ST_MAKEBBOX(lowerX, lowerY, upperX, upperY)
{{%/ bannerNote %}}

**Description**

Creates a `Geometry` representing a bounding box with the given boundaries.

* `lowerX`: `Double` input lower x value.
* `lowerY`: `Double` input lower y value.
* `upperX`: `Double` input upper x value.
* `upperY`: `Double` input upper y value.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_ASTEXT(carto.ST_MAKEBBOX(-91.8554869, 29.5060349, -91.8382077, 29.5307334)) AS bbox;
-- POLYGON ((-91.8554869 29.5060349, -91.8554869 29.5307334, -91.8382077 29.5307334, -91.8382077 29.5060349, -91.8554869 29.5060349))
```
