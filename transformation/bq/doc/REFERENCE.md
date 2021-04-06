## transformation

A set of functions to transform geoemtries on different ways. 

### ST_BUFFER

{{% bannerNote type="code" %}}
transformation.ST_BUFFER(geometry_to_buffer, radius, units, steps)
{{%/ bannerNote %}}

**Description**

Returns a buffer geometry from a `geometry_to_buffer` of a certain `radius` in a specific `units` made of a number of verices defined on `steps`.

* `geometry_to_buffer`: `GEOGRAPHY` to buffer.
* `radius`: `FLOAT64` for the buffer.
* `units`: `STRING` to choose from (`kilometers`,`miles`,`meters`)
* `steps`: `INT64` number of vertices to use for the creation of buffer geogrpahy.

**Constraints**

TO BE COMPLETED

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT bqcarto.transformation.ST_BUFFER(ST_GEOGPOINT(-74.00,40.7128),1,'kilometers',10);
```