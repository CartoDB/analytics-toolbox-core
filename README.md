## 🔥 UPDATE ##

We have finally completed the refactor and we have now ready all UDF functions under the new system. You can explore documentation about it in our [Official docuemntation](https://docs.carto.com/spatial-extension-bq/overview/getting-started/)

With this update now all functions are fully covered with test and we have a solid CI for new releases. You will notice that we have changed the locations of the functions, you should update to ensure you keep using the latest.

For example:

```sql
SELECT jslibs.h3.ST_H3(ST_GEOGPOINT(10,10),11)
```
it is now:

```sql
SELECT bqcarto.h3.ST_ASH3(ST_GEOGPOINT(10,10),11) 
```

# CARTO Spatial Extension

The [CARTO Spatial Extension](https://docs.carto.com/spatial-extension-bq/overview/getting-started/) for BigQuery is composed of a set of user-defined functions and procedures organized in a set of modules according to the functionality they offer. There are two types of modules: core modules, that are open source and free to use for anyone with a BigQuery account, and advanced modules, only available to CARTO account customers.

Visit the [SQL Reference](https://docs.carto.com/spatial-extension-bq/sql-reference/quadkey/) to see the full list of available modules. If you already have a CARTO account, please keep reading to learn how you can access the advanced modules.


## Modules

The project is divided into modules, which are a set of components under a common geospatial topic, like `quadkey` or `s2` indexes.

![image](https://user-images.githubusercontent.com/127803/113181089-b3b63080-9251-11eb-90c1-a834fce46496.png)

We recommend that you pin ```bqcarto``` in your BigQuery console.

### Quadkey

[Quadkey](https://wiki.openstreetmap.org/wiki/QuadTiles) is a geospatial index based on WebMercator tiles.

### Skel

This is a basic module meant to be used as the foundation to create new modules. It doesn't contain any useful functionality.

## Advanced Modules

In addition to the open source modules found here, CARTO also offers customers access to advanced modules to visualize and analyze data.

### Tiler

The [CARTO BigQuery Tiler](https://carto.com/bigquery/beta/) is a solution to visualize massive amounts of data in BigQuery. Here are a few screenshots of some visualizations created with it:

![alt text](screenshots/protected-areas.d0a592e5.jpg)

![alt text](screenshots/external-tools-s.80d694f9.jpg)

![alt text](screenshots/taxi-trips.500de518.jpg)
