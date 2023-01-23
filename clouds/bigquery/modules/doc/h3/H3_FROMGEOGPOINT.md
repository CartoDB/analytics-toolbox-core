## H3_FROMGEOGPOINT

```sql:signature
carto.H3_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the H3 cell index that the point belongs to in the required `resolution`. It will return `null` on error (invalid geography type or resolution out of bounds).

* `point`: `GEOGRAPHY` point to get the H3 cell from.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

**Example**

```sql
SELECT `carto-os`.carto.H3_FROMGEOGPOINT(ST_GEOGPOINT(40.4168, -3.7038), 4);
-- 847b59dffffffff
```

{% hint style="info" %}
**tip**

If you want the cells covered by a POLYGON see [H3_POLYFILL](#h3_polyfill).

{% endhint %}

{% hint style="info" %}
**ADDITIONAL EXAMPLES**

* [An H3 grid of Starbucks locations and simple cannibalization analysis](/analytics-toolbox-bigquery/examples/an-h3-grid-of-starbucks-locations-and-simple-cannibalization-analysis/)
* [Opening a new Pizza Hut location in Honolulu](/analytics-toolbox-bigquery/examples/opening-a-new-pizza-hut-location-in-honolulu/)
* [Computing the spatial autocorrelation of POIs locations in Berlin](/analytics-toolbox-bigquery/examples/computing-the-spatial-autocorrelation-of-pois-locations-in-berlin/)
* [Identifying amenity hotspots in Stockholm](/analytics-toolbox-bigquery/examples/amenity-hotspots-in-stockholm/)

{% endhint %}
