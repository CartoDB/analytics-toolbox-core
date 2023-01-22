## ST_GEOMFROMTWKB

```sql:signature
carto.ST_GEOMFROMTWKB(wkb)
```

**Description**

Creates a `Geometry` from the given Well-Known Binary representation (TWKB).

* `wkb`: `Array[Byte]` geom in TWKB format.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_ASTWKB(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)')) AS twkb
)
SELECT carto.ST_GEOMFROMTWKB(twkb) FROM t;
-- 4QgBz/HU1QXwwN6vAQA=
```