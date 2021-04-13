## squelleton

This folder contains the structure so be used as base when adding new modules to the CARTO Spatial Extension.

### EXAMPLE_ADD

{{% bannerNote type="code" %}}
squelleton.EXAMPLE_ADD (value)
{{%/ bannerNote %}}

**Description**

Adds 1 to input `value`.

* `value`: `INT64` This is an example inlined code <code>\`projectID.dataset.tablename\`</code>.

**Constraints**

Talk here about possible restrictions of use that your UDF could have.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.squelleton.EXAMPLE_ADD(5);
-- 6
```

Here is a tip:

{{% bannerNote type="note" title="tip"%}}
It's dangerous to go alone! Take this.
{{%/ bannerNote %}}

### VERSION

{{% bannerNote type="code" %}}
squelleton.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the squelleton module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.squelleton.VERSION();
-- 1.0.0
```
