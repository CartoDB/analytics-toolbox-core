## Reference

### SKEL

This folder contains the structure so be used as base when adding new modules to the CARTO Spatial Extension.

### EXAMPLE_ADD

{{% bannerNote type="code" %}}
skel.EXAMPLE_ADD (value)
{{%/ bannerNote %}}

**Description**

Adds 1 to input `value`.

* `value`: `INT` This is an example inlined code <code>\`projectID.dataset.tablename\`</code>.

**Constraints**

Talk here about possible restrictions of use that your UDF could have.

**Return type**

`INT`

**Example**

```sql
SELECT SFCARTO.SKEL.EXAMPLE_ADD(5);
-- 6
```

Here is a tip:

{{% bannerNote type="note" title="tip"%}}
It's dangerous to go alone! Take this.
{{%/ bannerNote %}}

#### VERSION

{{% bannerNote type="code" %}}
skel.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the skel library. Here is some sample code block:

```js
function skelExampleAdd(v) {
    return v + 1;
}
```

And a table:

| Column1 | Description |
| :----- | :------ |
|`taters`| Few and good. |
|`potatoes`| Boil 'em, mash 'em, stick 'em in a stew.|
|`chips`| Lovely big golden chips with a nice piece of fried fish.|
