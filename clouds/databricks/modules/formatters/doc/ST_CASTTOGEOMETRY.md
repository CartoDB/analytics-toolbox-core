### ST_CASTTOGEOMETRY

{{% bannerNote type="code" %}}
carto.ST_CASTTOGEOMETRY(geom)
{{%/ bannerNote %}}

**Description**

Casts `Geometry` subclass _g_ to a `Geometry`. This can be necessary e.g. when storing the output of `st_makePoint` as a `Geometry` in a case class.

* `geom`: `Geometry` input geom.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_CASTTOGEOMETRY(carto.ST_POINT(-76.09130, 18.42750));
-- 4QgBz/HU1QXwwN6vAQA=

```