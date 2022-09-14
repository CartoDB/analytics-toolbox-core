### ST_EXTENTTOGEOM

{{% bannerNote type="code" %}}
carto.ST_EXTENTTOGEOM(extent)
{{%/ bannerNote %}}

**Description**

Creates a `Geometry` representing the bounding box of the the given Geotrellis [Extent](https://geotrellis.readthedocs.io/en/latest/guide/core-concepts.html#extents).

* `extent`: `Extent` input extent.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_EXTENTFROMGEOM(carto.ST_MAKEBBOX(0, 0, 1, 1)) as extent
)
SELECT carto.ST_ASTEXT(carto.ST_EXTENTTOGEOM(extent)) FROM t;
-- POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))
```
