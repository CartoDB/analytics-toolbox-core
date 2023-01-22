## CREATE_CLUSTERKMEANS

```sql:signature
carto.CREATE_CLUSTERKMEANS(input, output_table, geom_column, number_of_clusters)
```

**Description**

Takes a set of points as input and partitions them into clusters using the k-means algorithm. Creates a new table with the same columns as `input` plus a `cluster_id` column with the cluster index for each of the input features.

* `input`: `VARCHAR` name of the table or literal SQL query to be clustered.
* `output_table`: `VARCHAR` name of the output table.
* `geom_column`: `VARCHAR` name of the column to be clusterd.
* `number_of_clusters`: `INT` number of clusters that will be generated.

{% hint style="warning" %}
**warning**

Keep in mid that due to some restrictions in the Redshift `VARCHAR` size, the maximum number of features (points) allow to be clustered is around 2500.

{% endhint %}

**Examples**

```sql
CALL carto.CREATE_CLUSTERKMEANS('my-schema.my-input-table', 'my-schema.my-output-table', 'geom', 5);
-- The table `my-schema.my-output-table` will be created
-- adding the column cluster_id to those in `my-schema.my-input-table`.
```

```sql
CALL carto.CREATE_CLUSTERKMEANS('select * my-schema.my-input-table', 'my-schema.my-output-table', 'geom', 5);
-- The table `my-schema.my-output-table` will be created
-- adding the column cluster_id to those returned in the input query.
```