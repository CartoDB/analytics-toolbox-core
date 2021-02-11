## Reference

### H3

[H3](https://eng.uber.com/h3/) is Uber’s Hexagonal Hierarchical Spatial Index. Full documentation of the project can be found at [h3geo](https://h3geo.org/docs).

#### h3.ST_ASH3

{{% bannerNote type="code" %}}
h3.ST_ASH3(geog, resolution)
{{%/ bannerNote %}}

* `geog`: `GEOGRAPHY` A **POINT** geography
* `resolution`: `INT64` A number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable)

Returns an H3 cell index where the point is placed in the required `resolution` as an `INT64` number. If will return `NULL` on error (invalid geography type or resolution out of bounds).

{{% bannerNote type="note" title="tip"%}}
If you want the HEX representation of the cell, you can call `h3.H3_ASHEX` with the number.
{{%/ bannerNote %}}

TODO: Mix with ST_H3_POLYFILLFROMGEOG <<<<<<<<<<<<


#### h3.VERSION

{{% bannerNote type="code" %}}
h3.VERSION()
{{%/ bannerNote %}}

Returns a `STRING` with the current version of the h3 library.