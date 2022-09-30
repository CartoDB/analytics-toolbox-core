### ST_DESTINATION

{{% bannerNote type="code" %}}
carto.ST_DESTINATION(geom, distance, bearing, units)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and a bearing in degrees. This uses the Haversine formula to account for global curvature.

* `geom`: `GEOMETRY` starting point.
* `distance`: `FLOAT8` distance from the origin point in the units specified.
* `bearing`: `FLOAT8` counter-clockwise angle from East, ranging from -180 to 180 (e.g. 0 is East, 90 is North, 180 is West, -90 is South).
* `units` (optional): `VARCHAR(15)` units of length. The supported options are: `miles`, `kilometers`, `degrees` or `radians`. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOMETRY`

**Examples**

```sql
SELECT carto.ST_DESTINATION(ST_MakePoint(-3.70325,40.4167), 10, 45);
-- POINT (-3.61964617436 40.4802614598)
```

```sql
SELECT carto.ST_DESTINATION(ST_MakePoint(-3.70325,40.4167), 10, 45, 'miles');
-- POINT (-3.56862505482 40.5189626778)
```
