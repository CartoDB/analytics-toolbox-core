## H3_POLYFILL

```sql:signature
H3_POLYFILL(geography, resolution [, mode])  
```

**Description**

Returns an array with all H3 cell indexes contained in the given polygon. There are three modes which decide if a H3 cell is contained in the polygon:  

* `geography`: `GEOGRAPHY` **polygon** or **multipolygon** representing the shape to cover. **GeometryCollections** are also allowed but they should contain **polygon** or **multipolygon** geographies. Non-Polygon types will not raise an error but will be ignored instead.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).
* `mode`: `STRING` `<center|contains|intersects>`. Optional. Defaults to 'center' mode.
  * `center` The center point of the H3 cell must be within the polygon
  * `contains` The H3 cell must be fully contained within the polygon (least inclusive)
  * `intersects` The H3 cell intersects in any way with the polygon (most inclusive)

Mode `center`:

![](h3_polyfill_mode_center.png)

Mode `intersects`:

![](h3_polyfill_mode_intersects.png)

Mode `contains`:

![](h3_polyfill_mode_contains.png)

**Return type**

`ARRAY<STRING>`

**Examples**

```sql
SELECT carto.H3_POLYFILL(
    TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4);
-- 842da29ffffffff
-- 843f725ffffffff
-- 843eac1ffffffff
-- 8453945ffffffff
-- ...
```

```sql
SELECT carto.H3_POLYFILL(
    TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4, 'center');
-- 842da29ffffffff
-- 843f725ffffffff
-- 843eac1ffffffff
-- 8453945ffffffff
-- ...
```

```sql
SELECT carto.H3_POLYFILL(
    TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4, 'contains');
-- 843f0cbffffffff
-- 842da01ffffffff
-- 843e467ffffffff
-- 843ea99ffffffff
-- 843f0c3ffffffff
-- ...
```

```sql
SELECT carto.H3_POLYFILL(
    TO_GEOGRAPHY('POLYGON ((30 1040 4020 4010 2030 10))')4'intersects');
-- 843f0cbffffffff
-- 842da01ffffffff
-- 843e467ffffffff
-- 843ea99ffffffff
-- 843f0c3ffffffff
-- 843ea91ffffffff
-- ...
```
