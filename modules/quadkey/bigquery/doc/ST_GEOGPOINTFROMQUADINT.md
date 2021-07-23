### ST_GEOGPOINTFROMQUADINT

{{% bannerNote type="code" %}}
quadkey.ST_GEOGPOINTFROMQUADINT(quadint)
{{%/ bannerNote %}}

**Description**

Returns the centroid for a given quadint.

* `quadint`: `INT64` quadint to get the centroid geography from.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.quadkey.ST_GEOGPOINTFROMQUADINT(4388);
-- 	POINT(33.75 22.2982994295938)
```