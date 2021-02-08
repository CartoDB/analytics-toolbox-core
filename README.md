## 🔥 UPDATE ##

CARTO is currently working on an entire refactor of the project. We plan to do significant changes to the modules, adding documentation, tests and continuous integration. We will be using different BigQuery projects so ETLs or calls to `jslibs.` will keep working. 

Our goal is to be ready by the end of February. You can still send PRs in the meantime if you want to, but we recommend waiting for this refactor to be done before investing any significant amount of work. Thanks!

# CARTO Spatial Extension

The CARTO Spatial Extension adds new geospatial capabilities to cloud data warehouses. This project is an evolution of [BigQuery JSLibs](https://carto.com/blog/spatial-functions-bigquery-uber/) with the objective to make it easy add extra modules and support new databases.

## Modules

The project is divided into modules, which are a set of components under a common geospatial topic, like `quadkey` or `s2` indexes.

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
