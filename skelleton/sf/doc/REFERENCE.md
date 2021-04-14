## squelleton

### ST_BUFFER

{{% bannerNote type="code" %}}
squelleton.ST_BUFFER(geog GEOGRAPHY, radius DOUBLE, units STRING, steps INT)
{{%/ bannerNote %}}

**Description**

Calculates a Geography buffer for input features for a given radius. Units supported are miles, kilometers, and degrees. https://turfjs.org/docs/#buffer

* `geog`: `GEOGRAPHY` input to be buffered.
* `radius`: `DOUBLE` distance to draw the buffer (negative values are allowed).
* `units`: `STRING` any of the options supported by turf units: miles, kilometers, and degrees.
* `steps`: `INT` number of steps.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT sfcarto.squelleton.ST_BUFFER(ST_POINT(-74.00, 40.7128), 1, 'kilometers', 10);
-- POLYGON((-73.9881354374691 40.7127993926494 ... 
```
