## ST_ASBINARY

```sql:signature
carto.ST_ASBINARY(geom)
```

**Description**

Returns `Geometry` _geom_ in WKB representation.

* `geom`: `Geometry` input geom.

**Return type**

`Array[Byte]`

**Example**

```sql
SELECT carto.ST_ASBINARY(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));
-- AIAAAAHAUwXX2/SH/UAybXCj1wo9AAAAAAAAAAA=
```
