### ST_ENVELOPE

{{% bannerNote type="code" %}}
carto.ST_ENVELOPE(geom)
{{%/ bannerNote %}}

**Description**

Returns a `Geometry` representing the bounding box of _geom_.

* `geom`: `Geometry` input geom.

**Return type**

`Geometry`

**Example**

``` sql
SELECT ST_ASTEXT(ST_ENVELOPE(ST_GEOMFROMWKT("LINESTRING(1 1, 2 3)")))
-- POLYGON ((1 1, 1 3, 2 3, 2 1, 1 1))
```