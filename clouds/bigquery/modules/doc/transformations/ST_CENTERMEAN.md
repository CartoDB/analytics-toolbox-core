### ST_CENTERMEAN

{{% bannerNote type="code" %}}
carto.ST_CENTERMEAN(geog)
{{%/ bannerNote %}}

**Description**

Takes a Feature or FeatureCollection and returns the mean center (average of its vertices).

* `geog`: `GEOGRAPHY` feature for which to compute the center.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT `carto-os`.carto.ST_CENTERMEAN(
  ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))")
);
-- POINT(25.3890912155939 29.7916831655627)
```

{{% bannerNote type="note" title="ADDITIONAL EXAMPLES"%}}
* [New police stations based on Chicago crime location clusters](/analytics-toolbox-bigquery/examples/new-police-stations-based-on-chicago-crime-location-clusters/)
{{%/ bannerNote %}}