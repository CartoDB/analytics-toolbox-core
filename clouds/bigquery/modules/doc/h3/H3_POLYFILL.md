## H3_POLYFILL

```sql:signature
carto.H3_POLYFILL(geography, resolution)
```

**Description**

Returns an array with all the H3 cell indexes **with centers** contained in a given polygon. It will return `null` on error (invalid geography type or resolution out of bounds). In case of lines, it will return the H3 cell indexes intersecting those lines. For a given point, it will return the H3 index of cell in which that point is contained.

````hint:info
**warning**

Lines polyfill is calculated by approximating S2 cells to H3 cells, in some cases some cells might be missing.

````

* `geography`: `GEOGRAPHY` representing the area to cover.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT `carto-os`.carto.H3_POLYFILL(
    ST_GEOGFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4);
-- 846b26bffffffff
-- 843e8b1ffffffff
-- 842d1e5ffffffff
-- 843ece5ffffffff
-- ...
```

````hint:info
**ADDITIONAL EXAMPLES**

* [Opening a new Pizza Hut location in Honolulu](/analytics-toolbox-bigquery/examples/opening-a-new-pizza-hut-location-in-honolulu/)

````
