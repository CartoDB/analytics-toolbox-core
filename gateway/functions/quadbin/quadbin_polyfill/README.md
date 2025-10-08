# QUADBIN_POLYFILL

Returns an array of Quadbin indices that cover the given geometry at a specified resolution.

## Signature

```sql
QUADBIN_POLYFILL(geom GEOMETRY, resolution INTEGER) -> ARRAY<BIGINT>
```

## Parameters

- `geom`: Input geometry to cover with quadbins
- `resolution`: Quadbin resolution level (0-26)

## Returns

Array of Quadbin indices covering the geometry

## Examples

```sql
-- Cover a point with quadbins at resolution 4
SELECT QUADBIN_POLYFILL(ST_POINT(-3.70325, 40.4165), 4);
-- Returns: [5209574053332910079]

-- Cover a polygon
SELECT QUADBIN_POLYFILL(
    ST_MAKEENVELOPE(-74.0, 40.7, -73.9, 40.8),
    10
);

-- Handle null values
SELECT QUADBIN_POLYFILL(NULL, 4);
-- Returns: NULL
```

## Implementation Details

### Redshift
- **Type**: AWS Lambda external function
- **Runtime**: Python 3.11
- **Memory**: 512 MB
- **Timeout**: 60 seconds
- **Batch size**: Up to 1000 rows

### Performance Considerations
- Higher resolutions generate more quadbins and take longer to process
- Consider using appropriate resolution for your use case
- For very large geometries, consider using lower resolutions

## See Also
- QUADBIN_BBOX
- QUADBIN_BOUNDARY
- QUADBIN_CENTER
