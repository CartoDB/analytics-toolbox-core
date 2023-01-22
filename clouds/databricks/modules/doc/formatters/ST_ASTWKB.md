## ST_ASTWKB

```sql:signature
carto.ST_ASTWKB(geom)
```

**Description**

Returns `Geometry` _geom_ in TWKB representation.

* `geom`: `Geometry` input geom.

**Return type**

`Array[Byte]`

**Example**

```sql
SELECT carto.ST_ASTWKB(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));
-- 4QgBz/HU1QXwwN6vAQA=
```