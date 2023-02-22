## ST_ENVELOPE

```sql:signature
carto.ST_ENVELOPE(geog)
```

**Description**

Takes any number of features and returns a rectangular Polygon that encompasses all vertices.

* `geog`: `ARRAY<GEOGRAPHY>` input features.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.ST_ENVELOPE([ST_GEOGPOINT(-75.833, 39.284), ST_GEOGPOINT(-75.6, 39.984), ST_GEOGPOINT(-75.221, 39.125)]);
-- POLYGON((-75.833 39.125, -75.68 39.125 ...
```
