## QUADBIN_AREA

```sql:signature
QUADBIN_AREA(quadbin)
```

**Description**

Returns the area in square meters for a given Quadbin cell. The area is calculated using the spherical surface area of the earth.

* `quadbin`: `INT64` Quadbin to get the area from.

**Return type**

`FLOAT64`

**Example**

```sql
SELECT carto.QUADBIN_AREA(5207251884775047167);
-- 4507012722233.0
```

````hint:info
The area calculation uses the spherical surface of the earth and returns values in square meters. Higher zoom levels (smaller cells) will have smaller areas, while lower zoom levels (larger cells) will have larger areas.
````