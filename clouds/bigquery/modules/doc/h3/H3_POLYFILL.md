## H3_POLYFILL

```sql:signature
H3_POLYFILL(geography, resolution)
```

**Description**

Returns an array with all the H3 cell indexes which intersect a given polygon, line or point. It will return `null` on error (invalid geography type or resolution out of bounds).

This function is equivalent to using [`H3_POLYFILL_MODE](h3#h3_polyfill) with mode `intersects`. If the input geometry is a polygon check that function for more options and better performance.

* `geography`: `GEOGRAPHY` representing the area to cover.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT carto.H3_POLYFILL(
    ST_GEOGFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4);
-- {846b26bffffffff,
--  843e8b1ffffffff,
--  842d1e5ffffffff,
--  843ece5ffffffff,
-- ...
```

Unnesting array result allow H3 visualization in Carto platfom.
```sql
SELECT
    h3
FROM
    UNNEST(
        carto.H3_POLYFILL(
            ST_GEOGFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4)
    ) as h3;
-- 846b26bffffffff
-- 843e8b1ffffffff
-- 842d1e5ffffffff
-- 843ece5ffffffff
-- ...
```
