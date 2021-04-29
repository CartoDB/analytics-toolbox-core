## transformations

<div class="badge core"></div>

### ST_BUFFER

{{% bannerNote type="code" %}}
transformations.ST_BUFFER(geog, radius, units, steps)
{{%/ bannerNote %}}

**Description**

Calculates a Geography buffer for input features for a given radius. Units supported are miles, kilometers, and degrees. https://turfjs.org/docs/#buffer

* `geog`: `GEOGRAPHY` input to be buffered.
* `radius`: `FLOAT64` distance to draw the buffer (negative values are allowed).
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, and degrees. If `NULL`the default value `kilometers` is used.
* `steps`: `INT64`|`NULL` number of steps. If `NULL` the default value `8` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_BUFFER(ST_GEOGPOINT(-74.00, 40.7128), 1, "kilometers", 10);
-- POLYGON((-73.9881354374691 40.7127993926494 ... 
```

### ST_CENTERMEAN

{{% bannerNote type="code" %}}
transformations.ST_CENTERMEAN(geog)
{{%/ bannerNote %}}

**Description**

Takes a Feature or FeatureCollection and returns the mean center. https://github.com/Turfjs/turf/tree/master/packages/turf-center-mean

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_CENTERMEAN(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"));
-- POINT(25.3890912155939 29.7916831655627)
```

### ST_CENTERMEDIAN

{{% bannerNote type="code" %}}
transformations.ST_CENTERMEDIAN(geog)
{{%/ bannerNote %}}

**Description**

Takes a FeatureCollection of points and calculates the median center, algorithimically. The median center is understood as the point that is requires the least total travel from all other points. https://github.com/Turfjs/turf/tree/master/packages/turf-center-median

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_CENTERMEDIAN(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"));
-- POINT(25.3783930513609 29.8376035441371)
```

### ST_CENTEROFMASS

{{% bannerNote type="code" %}}
transformations.ST_CENTEROFMASS(geog)
{{%/ bannerNote %}}

**Description**

Takes any Feature or a FeatureCollection and returns its center of mass using this formula: Centroid of Polygon. https://turfjs.org/docs/#centerOfMass

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_CENTEROFMASS(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"));
-- POINT(25.1730977433239 27.2789529273059) 
```

### ST_DESTINATION

{{% bannerNote type="code" %}}
transformations.ST_DESTINATION(startPoint, distance, bearing, units)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and bearing in degrees. This uses the Haversine formula to account for global curvature. https://turfjs.org/docs/#destination

* `origin`: `GEOGRAPHY` starting point.
* `distance`: `FLOAT64` distance from the origin point.
* `bearing`: `FLOAT64` ranging from -180 to 180.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, degrees or radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_DESTINATION(ST_GEOGPOINT(-3.70325,40.4167), 10, 45, "miles");
-- POINT(-3.56862505487045 40.5189626777536)
```

### ST_GREATCIRCLE

{{% bannerNote type="code" %}}
transformations.ST_GREATCIRCLE(startPoint, endPoint, npoints)
{{%/ bannerNote %}}

**Description**

Calculate great circles routes as LineString or MultiLineString. If the start and end points span the antimeridian, the resulting feature will be split into a MultiLineString. https://turfjs.org/docs/#greatCircle

* `startPoint`: `GEOGRAPHY` source point feature.
* `endPoint`: `GEOGRAPHY` destination point feature.
* `npoints`: `INT64`|`NULL` number of points. If `NULL` the default value `100` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_GREATCIRCLE(ST_GEOGPOINT(-3.70325,40.4167), ST_GEOGPOINT(-73.9385,40.6643), 20);
-- LINESTRING(-3.70325 40.4167 ... 
```

### ST_LINE_INTERPOLATE_POINT

{{% bannerNote type="code" %}}
transformations.ST_LINE_INTERPOLATE_POINT(geog, distance, units)
{{%/ bannerNote %}}

**Description**

Takes a LineString and returns a Point at a specified distance along the line. https://turfjs.org/docs/#along

* `geog`: `GEOGRAPHY` input line.
* `distance`: `FLOAT64` distance along the line.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, degrees and radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_LINE_INTERPOLATE_POINT(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 250, 'miles');
-- POINT(-74.297592068938 19.4498107103156) 
```

### VERSION

{{% bannerNote type="code" %}}
transformations.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the transformations module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.transformations.VERSION();
-- 1.1.0
```
