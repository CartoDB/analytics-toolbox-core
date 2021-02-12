## Reference

### QUADKEY

#### VERSION

{{% bannerNote type="code" %}}
quadkey.VERSION ()
{{%/ bannerNote %}}

Returns the current version of the quadkey library.

#### QUADINT_FROM_ZXY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROM_ZXY(z INT64, x INT64, y INT64)
{{%/ bannerNote %}}

Returns the quadint representation for tile x, y and a zoom z.

* `z`: `INT64` Level of zoom.
* `x`: `INT64` horizontal position of a tile.
* `y`: `INT64` vertical position of a tile.

#### ZXY_FROM_QUADINT

{{% bannerNote type="code" %}}
quadkey.ZXY_FROM_QUADINT(quadint INT64)
{{%/ bannerNote %}}

Returns the level of zoom z and coordinates x, y for a given quadint.

* `quadint`: `INT64` quadint we want to extract tile information from.

#### QUADINT_FROM_LOCATION

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROM_LOCATION(latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
{{%/ bannerNote %}}

Returns the quadint representation for a given level of detail and geographic coordinates.

* `latitude`: `FLOAT64` vertical coordinate of the map.
* `longitude`: `FLOAT64` horizontal coordinate of the map.
* `resolution`: `NUMERIC` Level of detail or zoom.

#### QUADINT_FROM_QUADKEY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROM_QUADKEY(quadkey STRING)
{{%/ bannerNote %}}

Transform a quadkey index to an equivalent quadint.

* `quadkey`: `STRING` quadkey we want to convert to quadint.

#### QUADKEY_FROM_QUADINT

{{% bannerNote type="code" %}}
quadkey.QUADKEY_FROM_QUADINT(quadint INT64)
{{%/ bannerNote %}}

Transform a quadint index to an equivalent quadkey.

* `quadint`: `INT64` quadint we want to convert to quadkey.

#### PARENT

{{% bannerNote type="code" %}}
quadkey.PARENT(quadint INT64)
{{%/ bannerNote %}}

Returns the current version of the quadkey library.

* `quadint`: `INT64` quadint we want to get the parent from.

#### CHILDREN

{{% bannerNote type="code" %}}
quadkey.CHILDREN(quadint INT64)
{{%/ bannerNote %}}

Returns the current version of the quadkey library.
* `quadint`: `INT64` quadint we want to get the children from.


#### KRING

{{% bannerNote type="code" %}}
quadkey.KRING(quadint INT64)
{{%/ bannerNote %}}

Returns the current version of the quadkey library.

* `quadint`: `INT64` quadint we want to get the KRING from.

#### SIBLING

{{% bannerNote type="code" %}}
quadkey.SIBLING(quadint INT64, direction STRING)
{{%/ bannerNote %}}

Returns the current version of the quadkey library.
* `quadint`: `INT64` quadint we want to get the sibling from.
* `direction`: `STRING` <code>'right'|'left'|'up'|'down'</code> direction where we want to move to extract the next sibling. 

#### BBOX

{{% bannerNote type="code" %}}
quadkey.BBOX(quadint INT64)
{{%/ bannerNote %}}

Returns the current version of the quadkey library.

* `quadint`: `INT64` quadint we want to get the bbox from.

#### ST_ASQUADINT

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINT(point GEOGRAPHY, resolution NUMERIC) 
{{%/ bannerNote %}}

Returns the current version of the quadkey library.

#### ST_ASQUADINTPOLYFILL

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINTPOLYFILL(geo GEOGRAPHY, resolution NUMERIC)
{{%/ bannerNote %}}

Returns the current version of the quadkey library.


#### ST_GEOGFROMQUADINT_BOUNDARY

{{% bannerNote type="code" %}}
quadkey.ST_GEOGFROMQUADINT_BOUNDARY(quadint INT64) 
{{%/ bannerNote %}}

Returns the current version of the quadkey library.




#### skel.EXAMPLE_ADD

{{% bannerNote type="code" %}}
skel.EXAMPLE_ADD (value)
{{%/ bannerNote %}}

* `value`: `INT64` This is an example inlined code <code>\`projectID.dataset.tablename\`</code>.

Here is a tip:

{{% bannerNote type="note" title="tip"%}}
It's dangerous to go alone! Take this.
{{%/ bannerNote %}}