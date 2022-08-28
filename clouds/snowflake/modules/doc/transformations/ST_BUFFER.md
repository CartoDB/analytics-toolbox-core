### ST_BUFFER

{{% bannerNote type="code" %}}
carto.ST_BUFFER(geog, distance [, segments])
{{%/ bannerNote %}}

**Description**

Calculates a buffer for the input features for a given distance.

* `geog`: `GEOGRAPHY` input to be buffered.
* `distance`: `DOUBLE` distance of the buffer around the input geography. The value is in meters. Negative values are allowed.
* `segments` (optional): `INTEGER` number of segments used to approximate a quarter circle. The default value is `8`.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT carto.ST_BUFFER(ST_POINT(-74.00, 40.7128), 1000);
-- { "coordinates": [ [ [ -73.98813543746913, 40.712799392649444 ], ...
```

``` sql
SELECT carto.ST_BUFFER(ST_POINT(-74.00, 40.7128), 1000, 10);
-- { "coordinates": [ [ [ -73.98813543746913, 40.712799392649444 ], ...
```