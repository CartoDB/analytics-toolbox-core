### ST_DESTINATION

{{% bannerNote type="code" %}}
transformations.ST_DESTINATION(geom, distance, bearing, units)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and bearing in degrees. This uses the Haversine formula to account for global curvature.

* `geom`: `GEOMETRY` starting point.
* `distance`: `FLOAT8` distance from the origin point.
* `bearing`: `FLOAT8` ranging from -180 to 180.
* `units` (optional): `VARCHAR(15)` units of length, the supported options are: miles, kilometers, degrees or radians. By default `units` is `kilometers`.

**Return type**

`GEOMETRY`

**Examples**

```sql
SELECT transformations.ST_DESTINATION(ST_MakePoint(-3.70325,40.4167), 10, 45);
-- POINT (-3.619646 40.480261)
```

```sql
SELECT transformations.ST_DESTINATION(ST_MakePoint(-3.70325,40.4167), 10, 45, 'miles');
-- POINT (-3.568625 40.518963)
```