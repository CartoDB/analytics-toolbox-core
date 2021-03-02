## Reference

### QUADKEY

#### VERSION

{{% bannerNote type="code" %}}
quadkey.VERSION ()
{{%/ bannerNote %}}

Returns the current version of the quadkey library.

#### QUADINT_FROMZXY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROMZXY(z INT64, x INT64, y INT64)
{{%/ bannerNote %}}

Returns the quadint representation for tile x, y and a zoom z.

* `z`: `INT64` Level of zoom.
* `x`: `INT64` horizontal position of a tile.
* `y`: `INT64` vertical position of a tile.

#### ZXY_FROMQUADINT

{{% bannerNote type="code" %}}
quadkey.ZXY_FROMQUADINT(quadint INT64)
{{%/ bannerNote %}}

Returns the level of zoom z and coordinates x, y for a given quadint.

* `quadint`: `INT64` quadint we want to extract tile information from.

#### LONGLAT_ASQUADINT

{{% bannerNote type="code" %}}
quadkey.LONGLAT_ASQUADINT(longitude FLOAT64, latitude FLOAT64, resolution INT64)
{{%/ bannerNote %}}

Returns the quadint representation for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT64` horizontal coordinate of the map.
* `latitude`: `FLOAT64` vertical coordinate of the map.
* `resolution`: `INT64` Level of detail or zoom.

#### QUADINT_FROMQUADKEY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROMQUADKEY(quadkey STRING)
{{%/ bannerNote %}}

Transform a quadkey index to an equivalent quadint.

* `quadkey`: `STRING` quadkey we want to convert to quadint.

#### QUADKEY_FROMQUADINT

{{% bannerNote type="code" %}}
quadkey.QUADKEY_FROMQUADINT(quadint INT64)
{{%/ bannerNote %}}

Transform a quadint index to an equivalent quadkey.

* `quadint`: `INT64` quadint we want to convert to quadkey.

#### PARENT

{{% bannerNote type="code" %}}
quadkey.PARENT(quadint INT64)
{{%/ bannerNote %}}

Returns the parent quadint of a given quadint. A parent quadint is a quadint of smaller level of detail (zoom - 1) which contains the current quadint.

* `quadint`: `INT64` quadint we want to get the parent from.

#### CHILDREN

{{% bannerNote type="code" %}}
quadkey.CHILDREN(quadint INT64)
{{%/ bannerNote %}}

Returns an array with the children quadint of a given quadint. A children quadint is a quadint of bigger level of detail (zoom + 1) which is contained by the current quadint. Each quadint has 4 children.

* `quadint`: `INT64` quadint we want to get the children from.

#### SIBLING

{{% bannerNote type="code" %}}
quadkey.SIBLING(quadint INT64, direction STRING)
{{%/ bannerNote %}}

Returns the quadint directly next to the given quadint at the same level of zoom. The direction must be sent as argument and currently horizontal/vertical movements are allowed.

* `quadint`: `INT64` quadint we want to get the sibling from.
* `direction`: `STRING` <code>'right'|'left'|'up'|'down'</code> direction where we want to move to extract the next sibling. 

#### KRING

{{% bannerNote type="code" %}}
quadkey.KRING(quadint INT64)
{{%/ bannerNote %}}

Returns an array with all the quadints directly next to the given quadint at the same level of zoom. We consider diagonal, horizontal and vertical nearby quadints and the current quadint so KRING should always return 9 quadints.

* `quadint`: `INT64` quadint we want to get the KRING from.

#### BBOX

{{% bannerNote type="code" %}}
quadkey.BBOX(quadint INT64)
{{%/ bannerNote %}}

Returns the boundary box of a given quadint. This boundary box contains the minimum and maximum longitude and latitude.

* `quadint`: `INT64` quadint we want to get the bbox from.

#### ST_ASQUADINT

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINT(point GEOGRAPHY, resolution INT64) 
{{%/ bannerNote %}}

Converts a given point at given level of detail to a quadint.

* `point`: `GEOGRAPHY` point we want to get the quadint from.
* `resolution`: `INT64` Level of detail or zoom.

#### ST_ASQUADINTPOLYFILL

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINTPOLYFILL(geo GEOGRAPHY, resolution INT64)
{{%/ bannerNote %}}

Returns an array of quadints contained by the given geography at a given level of detail.

* `geo`: `GEOGRAPHY` geography we want to extract the quadints from.
* `resolution`: `INT64` Level of detail or zoom.

#### ST_GEOGFROMQUADINT_BOUNDARY

{{% bannerNote type="code" %}}
quadkey.ST_GEOGFROMQUADINT_BOUNDARY(quadint INT64) 
{{%/ bannerNote %}}

Returns the geography boundary for a given quadint. We extract the boundary the same way as when we calculate the bbox, then enclose it in a GEOJSON and finally transform it to geography.

* `quadint`: `INT64` quadint we want to get the boundary geography from.