## ST_GENERATEPOINTS

```sql:signature
ST_GENERATEPOINTS(geog, npoints)
```

**Description**

Generates randomly placed points inside a polygon and returns them in an array of geographies.

The distribution of the generated points is spherically uniform (i.e. if the coordinates are interpreted as longitude and latitude on a sphere); this means that WGS84 coordinates will be only approximately uniformly distributed, since WGS84 is based on an ellipsoidal model.

* `geog`: `GEOGRAPHY` a polygon; the random points generated will be inside this polygon.
* `npoints`: `INT64` number of points to generate.

**Return type**

`ARRAY<GEOGRAPHY>`

**Example**

```sql
WITH blocks AS (
  SELECT d.total_pop, g.blockgroup_geom
  FROM `bigquery-public-data.geo_census_blockgroups.us_blockgroups_national` AS g
  INNER JOIN `bigquery-public-data.census_bureau_acs.blockgroup_2018_5yr` AS d ON g.geo_id = d.geo_id
  WHERE g.county_name = 'Sonoma County'
),
point_lists AS (
  SELECT carto.ST_GENERATEPOINTS(blockgroup_geom, CAST(total_pop AS INT64)) AS points
  FROM blocks
)
SELECT points FROM point_lists CROSS JOIN point_lists.points
```
