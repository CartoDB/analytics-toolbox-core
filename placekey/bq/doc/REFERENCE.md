## placekey

[Placekey](https://www.placekey.io/faq) is a free and open universal standard identifier for any physical place, so that the data pertaining to those places can be shared across organizations easily. Since Placekey is based on H3, here we offer a way to transform to and from that index and delegate any extra functionality to H3 itself.

You can learn more about Placekey on [their website](https://www.placekey.io/) or in the [Overview section](../../overview/spatial-indexes/#placekey) of this documentation.

### H3_ASPLACEKEY

{{% bannerNote type="code" %}}
placekey.H3_ASPLACEKEY(h3index)
{{%/ bannerNote %}}

**Description**

Returns the placekey equivalent to the given H3 index.

* `h3index`: `INT64` H3 identifier.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.placekey.H3_ASPLACEKEY(596645165859340287);
-- @ff7-swh-m49
```

### PLACEKEY_ASH3

{{% bannerNote type="code" %}}
placekey.PLACEKEY_ASH3(placekey)
{{%/ bannerNote %}}

**Description**

Returns the H3 index equivalent to the given placekey.

* `placekey`: `STRING` Placekey identifier.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.placekey.PLACEKEY_ASH3("@ff7-swh-m49");
-- 623666763623563263
```

### ISVALID

{{% bannerNote type="code" %}}
placekey.ISVALID(placekey)
{{%/ bannerNote %}}

**Description**

Returns a boolean value `true` when the given string represents a valid Placekey, `false` otherwise.

* `placekey`: `STRING` Placekey identifier.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT bqcarto.placekey.ISVALID("@ff7-swh-m49");
-- true
```

```sql
SELECT bqcarto.placekey.ISVALID("ff7-swh-m49");
-- true
```

```sql
SELECT bqcarto.placekey.ISVALID("x");
-- false
```

### VERSION

{{% bannerNote type="code" %}}
placekey.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the placekey module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.placekey.VERSION();
-- 1.0.1
