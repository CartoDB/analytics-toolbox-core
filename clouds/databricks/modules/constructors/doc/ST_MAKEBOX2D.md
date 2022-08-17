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
select ST_ASTEXT(ST_MAKEBOX2D(ST_MAKEPOINT(-91.8554869, 29.5060349), ST_MAKEPOINT(-91.8382077, 29.5307334))) as bbox          
-- POLYGON ((-91.8554869 29.5060349, -91.8554869 29.5307334, -91.8382077 29.5307334, -91.8382077 29.5060349, -91.8554869 29.5060349))
```
