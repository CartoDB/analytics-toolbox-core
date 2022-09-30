### ST_MAKEBOX2D

{{% bannerNote type="code" %}}
carto.ST_MAKEBOX2D(lowerleft, upperRight)
{{%/ bannerNote %}}

**Description**

Creates a `Geometry` representing a bounding box defined by the given `Points`.

* `lowerleft`: `Point` input lower left Point.
* `upperRight`: `Point` input upper right Point.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_ASTEXT(
  carto.ST_MAKEBOX2D(
    carto.ST_MAKEPOINT(-91.85548, 29.50603),
    carto.ST_MAKEPOINT(-91.83820, 29.53073)
  )
) AS bbox;
-- POLYGON ((-91.85548 29.50603, -91.85548 29.53073, -91.8382 29.53073, -91.8382 29.50603, -91.85548 29.50603))
```
