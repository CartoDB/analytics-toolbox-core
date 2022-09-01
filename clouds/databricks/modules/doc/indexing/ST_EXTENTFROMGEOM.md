### ST_EXTENTFROMGEOM

{{% bannerNote type="code" %}}
carto.ST_EXTENTFROMGEOM(geom)
{{%/ bannerNote %}}

**Description**

Creates a Geotrellis [Extent](https://geotrellis.readthedocs.io/en/latest/guide/core-concepts.html#extents) from the given `Geometry`.

* `geom`: `Geometry` input Geometry.

**Return type**

`Extent`

**Example**

```sql
SELECT carto.ST_EXTENTFROMGEOM(carto.ST_MAKEBBOX(0, 0, 1, 1))
-- {"xmin": 0, "ymin": 0, "xmax": 1, "ymax": 1}
```
