### ST_CENTEROFMASS

{{% bannerNote type="code" %}}
carto.ST_CENTEROFMASS(geog)
{{%/ bannerNote %}}

**Description**

Takes any Feature or a FeatureCollection and returns its center of mass (also known as centroid).

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT carto.ST_CENTEROFMASS(TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- { "coordinates": [ 25.454545454545453, 26.96969696969697 ], "type": "Point" }
```

{{% bannerNote type="note" title="ADDITIONAL EXAMPLES"%}}
* [Computing US airport connections and route interpolations](/analytics-toolbox-snowflake/examples/computing-us-airport-connections-and-route-interpolations/)
{{%/ bannerNote %}}