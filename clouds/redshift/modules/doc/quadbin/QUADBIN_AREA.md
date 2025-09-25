## QUADBIN_AREA

```sql:signature
QUADBIN_AREA(quadbin)
```

**Description**

Returns the area in square meters for a given Quadbin cell. The area is calculated using the spherical surface area of the earth.

* `quadbin`: `BIGINT` Quadbin to get the area from.

**Return type**

`FLOAT`

**Example**

```sql
SELECT carto.QUADBIN_AREA(5207251884775047167);
-- 428.32918206449995
```

````hint:info
The area calculation uses the spherical surface of the earth. The units depend on the coordinate system used by the ST_AREA function. Higher zoom levels (smaller cells) will have smaller areas, while lower zoom levels (larger cells) will have larger areas.
````