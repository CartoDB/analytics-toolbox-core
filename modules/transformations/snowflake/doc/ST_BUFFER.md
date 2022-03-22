### ST_BUFFER

{{% bannerNote type="code" %}}
carto.ST_BUFFER(geog, radius, units, steps)
{{%/ bannerNote %}}

**Description**

Calculates a Geography buffer for input features for a given radius. Units supported are miles, kilometers, and degrees.

* `geog`: `GEOGRAPHY` input to be buffered.
* `radius`: `DOUBLE` distance to draw the buffer (negative values are allowed).
* `units`: `STRING`|`NULL` units of length, the supported options are: miles, kilometers, and degrees. If `NULL`the default value `kilometers` is used.
* `steps`: `DOUBLE`|`NULL` number of steps. If `NULL` the default value `8` is used.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT carto.ST_BUFFER(ST_POINT(-74.00, 40.7128), 1, 'kilometers', 10);
-- { "coordinates": [ [ [ -73.98813543746913, 40.712799392649444 ], ...
```