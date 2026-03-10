## QUADBIN_POLYFILL

```sql:signature
QUADBIN_POLYFILL(geojson_or_wkt, resolution)
```

**Description**

Returns an array of Quadbins that intersect with the given geometry at a requested resolution. The geometry can be provided as a WKT string or a GeoJSON string.

* `geojson_or_wkt`: `STRING` geometry to extract the Quadbins from (WKT or GeoJSON).
* `resolution`: `INT` level of detail or zoom.

**Return type**

`ARRAY<BIGINT>`

**Example**

```sql
SELECT carto.QUADBIN_POLYFILL(
    'POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))',
    17
);
-- [5265786693153193983, 5265786693163941887,
--  5265786693164466175, 5265786693164204031,
--  5265786693164728319, 5265786693165514751]
```
