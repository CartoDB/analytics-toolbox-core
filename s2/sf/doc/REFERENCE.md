## s2

Our S2 module is based on a port of the official s2 geometry library created by Google. For more information about S2 check the [library's website](http://s2geometry.io/) or the [Overview section](/spatial-extension-bq/spatial-indexes/overview/#s2) of this documentation.

### ID_FROMHILBERTQUADKEY

{{% bannerNote type="code" %}}
S2.ID_FROMHILBERTQUADKEY(hquadkey)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a Hilbert quadkey (a.k.a Hilbert curve quadtree ID) into a S2 cell ID.

* `hquadkey`: `STRING` Hilbert quadkey to be converted.

**Return type**

`BIGINT`

**Example**

```sql
SELECT SFCARTO.S2.ID_FROMHILBERTQUADKEY('0/30002221');
-- 1735346007979327488
```

### HILBERTQUADKEY_FROMID

{{% bannerNote type="code" %}}
S2.HILBERTQUADKEY_FROMID(id)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a S2 cell ID into a Hilbert quadkey (a.k.a Hilbert curve quadtree ID).

* `id`: `BIGINT` S2 cell ID to be converted.

**Return type**

`STRING`

**Example**

```sql
SELECT SFCARTO.S2.HILBERTQUADKEY_FROMID(1735346007979327488);
-- 0/30002221
```

### LONGLAT_ASID

{{% bannerNote type="code" %}}
S2.LONGLAT_ASID(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID for a given longitude, latitude and zoom resolution.

* `longitude`: `DOUBLE` horizontal coordinate on the map.
* `latitude`: `DOUBLE` vertical coordinate on the map.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT SFCARTO.S2.LONGLAT_ASID(40.4168, -3.7038, 8);
-- 1735346007979327488
```

### ST_ASID

{{% bannerNote type="code" %}}
S2.ST_ASID(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the ID from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT SFCARTO.S2.ST_ASID(ST_POINT(40.4168, -3.7038), 8);
-- 1735346007979327488
```

### ST_BOUNDARY

{{% bannerNote type="code" %}}
S2.ST_BOUNDARY(id)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given S2 cell ID. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it into geography.

* `id`: `BIGINT` S2 cell ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT SFCARTO.S2.ST_BOUNDARY(1735346007979327488);
-- { "coordinates": [ [ [ 40.30886257091771, -3.8626948530725476 ], [ 40.30886257091771, -3.6086596856604585 ] ...
```

### VERSION

{{% bannerNote type="code" %}}
S2.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the S2 module.

**Return type**

`STRING`

**Example**

```sql
SELECT SFCARTO.S2.VERSION();
-- 1.2.10
