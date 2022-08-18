### st_translate
`Geometry st_translate(Geometry geom, Double deltaX, Double deltaY)`

Returns the `Geometry` produced when _geom_ is translated by _deltaX_ and _deltaY_.
### ST_TRANSLATE

{{% bannerNote type="code" %}}
carto.ST_TRANSLATE(geom, deltaX, deltaY)
{{%/ bannerNote %}}

**Description**

Returns the `Geometry` produced when _geom_ is translated by _deltaX_ and _deltaY_.

* `geom`: `Geometry` input geom.
* `deltaX`: `Double` distance x to be tralslated.
* `deltaY`: `Double` distance y to be tralslated.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  select ST_POINT(0, 0) as point
)
SELECT ST_ASTEXT(ST_TRANSLATE(point, 1, 2)) FROM t
-- POINT (1 2)
```