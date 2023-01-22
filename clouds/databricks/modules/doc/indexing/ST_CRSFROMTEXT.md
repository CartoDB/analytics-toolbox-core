## ST_CRSFROMTEXT

```sql:signature
carto.ST_CRSFROMTEXT(proj4)
```

**Description**

Creates a CoordinateReferenceSystem from a PROJ.4 projection parameter string.

* `proj4`: `String` input projection parameter string.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_CRSFROMTEXT('+proj=merc +lat_ts=56.5 +ellps=GRS80');
-- +proj=merc +lat_ts=56.5 +ellps=GRS80
```