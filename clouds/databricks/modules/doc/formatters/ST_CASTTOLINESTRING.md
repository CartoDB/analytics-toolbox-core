## ST_CASTTOLINESTRING

```sql:signature
carto.ST_CASTTOLINESTRING(geom)
```

**Description**

Casts `Geometry` _g_ to a `LineString`.

* `geom`: `Geometry` input geom.

**Return type**

`LineString`

**Example**

```sql
SELECT carto.ST_CASTTOLINESTRING(carto.ST_GEOMFROMWKT('LINESTRING(75 29,77 29,77 27, 75 29)'));
-- 4QgBz/HU1QXwwN6vAQA=
```