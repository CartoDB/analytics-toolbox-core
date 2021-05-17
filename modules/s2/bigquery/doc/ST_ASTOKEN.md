### ST_ASTOKEN

{{% bannerNote type="code" %}}
s2.ST_ASTOKEN(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the ID from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`STRING` * S2 cell hexified ID.

**Example**

TO DO