### ST_COORDDIM

{{% bannerNote type="code" %}}
carto.ST_COORDDIM(geom)
{{%/ bannerNote %}}

**Description**

Returns the number of dimensions of the coordinates of `Geometry` _geom_.

* `geom`: `Geometry` input geom.

**Return type**

`Int`

**Example**

``` sql
SELECT carto.ST_COORDDIM(carto.ST_MAKEPOINTM(1, 2, 3));
-- 3 
```