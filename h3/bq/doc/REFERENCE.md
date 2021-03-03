## Reference

### H3

[H3](https://eng.uber.com/h3/) is Uber’s Hexagonal Hierarchical Spatial Index. Full documentation of the project can be found at [h3geo](https://h3geo.org/docs).

#### h3.ST_ASH3

{{% bannerNote type="code" %}}
h3.ST_ASH3(geog, resolution) -> INT64
{{%/ bannerNote %}}

* `geog`: `GEOGRAPHY` A **POINT** geography.
* `resolution`: `INT64` A number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

Returns an H3 cell index where the point is placed in the required `resolution` as an `INT64` number. If will return `NULL` on error (invalid geography type or resolution out of bounds).

{{% bannerNote type="note" title="tip"%}}
If you want the HEX representation of the cell, you can call [H3_ASHEX](#h3.H3ASHEX) with the output number.
{{%/ bannerNote %}}

{{% bannerNote type="note" title="tip"%}}
If you want the cells covered by a POLYGON see [ST_ASH3_POLYFILL](#h3.ST_ASH3_POLYFILL).
{{%/ bannerNote %}}

#### h3.LONGLAT_ASH3

{{% bannerNote type="code" %}}
h3.LONGLAT_ASH3(longitude, latitude, resolution) -> INT64
{{%/ bannerNote %}}

* `latitude`: `FLOAT64` The point latitude in **degrees**.
* `longitude`: `FLOAT64` The point latitude in **degrees**.
* `resolution`: `INT64` A number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

Returns an H3 cell index where the point is placed in the required `resolution` as an `INT64` number. If will return `NULL` on error (resolution out of bounds).

#### h3.ST_ASH3_POLYFILL

{{% bannerNote type="code" %}}
h3.ST_ASH3_POLYFILL(geography, resolution) -> ARRAY<INT64>
{{%/ bannerNote %}}

* `geography`: `GEOGRAPHY` A **POLYGON** or **MULTIPOLYGON** representing the area to cover.
* `longitude`: `FLOAT64` The point latitude in **degrees**.
* `resolution`: `INT64` A number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

Returns all hexagons **with centers** contained in a given polygon. If will return `NULL` on error (invalid geography type or resolution out of bounds).

#### h3.VERSION

{{% bannerNote type="code" %}}
h3.VERSION()
{{%/ bannerNote %}}

Returns a `STRING` with the current version of the h3 library.