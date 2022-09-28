### ST_BUFFER

{{% bannerNote type="code" %}}
carto.ST_BUFFER(geog, radius, units, steps)
{{%/ bannerNote %}}

**Description**

Calculates a Geography buffer for input features for a given radius. Units supported are miles, kilometers, and degrees.

* `geog`: `GEOGRAPHY` input to be buffered.
* `radius`: `FLOAT64` distance to draw the buffer (negative values are allowed).
* `units`: `STRING`|`NULL` units of length, the supported options are: miles, kilometers, and degrees. If `NULL`the default value `kilometers` is used.
* `steps`: `INT64`|`NULL` number of steps. If `NULL` the default value `8` is used.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT `carto-os`.carto.ST_BUFFER(ST_GEOGPOINT(-74.00, 40.7128), 1, "kilometers", 10);
-- POLYGON((-73.9881354374691 40.7127993926494 ...
```

{{% bannerNote type="note" title="ADDITIONAL EXAMPLES"%}}
* [Bikeshare stations within a San Francisco buffer](/analytics-toolbox-bigquery/examples/bikeshare-stations-within-a-san-francisco-buffer/)
* [Store cannibalization: quantifying the effect of opening new stores on your existing network](/analytics-toolbox-bigquery/examples/store-cannibalization/)
* [Opening a new Pizza Hut location in Honolulu](/analytics-toolbox-bigquery/examples/opening-a-new-pizza-hut-location-in-honolulu/)
{{%/ bannerNote %}}