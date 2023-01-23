## H3_BOUNDARY

```sql:signature
carto.H3_BOUNDARY(index)
```

**Description**

Returns a geography representing the H3 cell. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT `carto-os`.carto.H3_BOUNDARY('847b59dffffffff');
-- POLYGON((40.4650636223452 -3.9352772457965, 40.5465406026705 ...
```

{% hint style="info" %}
**ADDITIONAL EXAMPLES**

* [An H3 grid of Starbucks locations and simple cannibalization analysis](/analytics-toolbox-bigquery/examples/an-h3-grid-of-starbucks-locations-and-simple-cannibalization-analysis/)

{% endhint %}
