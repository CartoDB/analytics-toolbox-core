## Reference

### TURF

For more detailed reference on turf visit https://turfjs.org/docs/.
#### Examples:

```
ST_BUFFER(geometry_to_buffer GEOGRAPHY, radius NUMERIC, units STRING, steps NUMERIC)
```
As taken from https://turfjs.org/docs/#buffer

``` sql
SELECT jslibs.turf.ST_BUFFER(ST_GEOGPOINT(-74.00,40.7128),1,'kilometers',10) as geo
```

#### VERSION

{{% bannerNote type="code" %}}
turf.VERSION()
{{%/ bannerNote %}}

Returns the current version of the turf library.

#### BBOX

{{% bannerNote type="code" %}}
turf.BBOX(geojson STRING)
{{%/ bannerNote %}}

Takes a set of features, calculates the bbox of all input features, and returns a bounding box (minX, minY, maxX, maxY).
https://turfjs.org/docs/#bbox

* `geojson`: `STRING` geojson to extract the bounding box from.

#### BUFFER

{{% bannerNote type="code" %}}
turf.BUFFER(geojson STRING,radius NUMERIC, options STRUCT<unit STRING,steps NUMERIC>)
{{%/ bannerNote %}}

Calculates a GeoJSON buffer for input features for a given radius. Units supported are miles, kilometers, and degrees. https://turfjs.org/docs/#buffer

* `geojson`: `STRING` input to be buffered.
* `radius`: `NUMERIC` distance to draw the buffer (negative values are allowed).
* `options`: `STRUCT<unit STRING,steps NUMERIC>` Option parameters:

| Option | Description |
| :----- | :------ |
| `unit`| `STRING` any of the options supported by turf units: miles, kilometers, and degrees. |
| `steps`| `NUMERIC` number of steps. |

#### SIMPLIFY

{{% bannerNote type="code" %}}
turf.SIMPLIFY(geojson STRING, options STRUCT<tolerance NUMERIC, highQuality BOOL>)
{{%/ bannerNote %}}

Takes a GeoJSON object and returns a simplified GeoJSON version. Internally uses simplify-js to perform simplification using the Ramer-Douglas-Peucker algorithm. https://turfjs.org/docs/#simplify

* `geojson`: `STRING` object to be simplified.
* `options`: `STRUCT<tolerance NUMERIC, highQuality BOOL>` Option parameters:

| Option | Description |
| :----- | :------ |
| `tolerance`| `NUMERIC` simplification tolerance. |
| `highQuality`| `BOOL` whether or not to spend more time to create a higher-quality simplification with a different algorithm. |

#### ST_BUFFER

{{% bannerNote type="code" %}}
turf.ST_BUFFER(geojson GEOGRAPHY, radius NUMERIC, units STRING, steps NUMERIC)
{{%/ bannerNote %}}

Calculates a Geography buffer for input features for a given radius. Units supported are miles, kilometers, and degrees. https://turfjs.org/docs/#buffer

* `geojson`: `STRING` input to be buffered.
* `radius`: `NUMERIC` distance to draw the buffer (negative values are allowed).
* `units`: `STRING` any of the options supported by turf units: miles, kilometers, and degrees.
* `steps`: `NUMERIC` number of steps.

``` sql
SELECT jslibs.turf.ST_BUFFER(ST_GEOGPOINT(-74.00,40.7128),1,'kilometers',10) as geo
```

#### ST_SIMPLIFY

{{% bannerNote type="code" %}}
turf.ST_SIMPLIFY(geojson GEOGRAPHY, tolerance NUMERIC)
{{%/ bannerNote %}}

Takes a GeoJSON object and returns a simplified Geography version. Internally uses simplify-js to perform simplification using the Ramer-Douglas-Peucker algorithm. https://turfjs.org/docs/#simplify
This function is the equivalent to SIMPLIFY but apart from returning a Geography, has the option "highQuality" set to true.

* `geojson`: `GEOGRAPHY` object to be simplified.
* `tolerance`: `NUMERIC` simplification tolerance.