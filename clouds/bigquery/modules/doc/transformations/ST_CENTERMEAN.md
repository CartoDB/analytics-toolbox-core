## ST_CENTERMEAN

```sql:signature
carto.ST_CENTERMEAN(geog)
```

**Description**

Takes a Feature or FeatureCollection and returns the mean center (average of its vertices).

* `geog`: `GEOGRAPHY` feature for which to compute the center.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT `carto-os`.carto.ST_CENTERMEAN(
  ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))")
);
-- POINT(25.3890912155939 29.7916831655627)
```

````hint:info
**ADDITIONAL EXAMPLES**

* [New police stations based on Chicago crime location clusters](/analytics-toolbox-bigquery/examples/new-police-stations-based-on-chicago-crime-location-clusters/)

````
