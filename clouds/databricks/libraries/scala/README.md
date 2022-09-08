# CARTO Analytics Toolbox

CARTO Analytics Toolbox for Databricks provides geospatial functionality leveraging the GeoMesa SparkSQL capabilities. It implements Spatial Hive UDFs and consists of the following modules:

* `core` with Hive GIS UDFs (depends on [GeoMesa](https://github.com/locationtech/geomesa), [GeoTrellis](https://github.com/locationtech/geotrellis), and [Hiveless](https://github.com/azavea/hiveless))

## Quick Start

```scala
resolvers ++= Seq(
  // for snapshot artifacts only
  "s01-oss-sonatype" at "https://s01.oss.sonatype.org/content/repositories/snapshots"
)

libraryDependencies ++= Seq(
  "com.carto.analyticstoolbox" %% "core" % "<latest version>"
)
```

## Supported GIS functions (core)

```sql
CREATE OR REPLACE FUNCTION st_geometryFromText as 'com.carto.analyticstoolbox.core.ST_GeomFromWKT';
CREATE OR REPLACE FUNCTION st_intersects as 'com.carto.analyticstoolbox.core.ST_Intersects';
CREATE OR REPLACE FUNCTION st_simplify as 'com.carto.analyticstoolbox.core.ST_Simplify';
 -- ...and more
```

The full list of supported functions can be found [here](./libraries/scala/core/src/main/resources/sql/createUDFs.sql).

## Spatial Query Optimizations

There are two types of supported optimizations: `ST_Intersects` and `ST_Contains`, which allow Spark to push down predicates when possible.

To enable optimizations:

```scala
com.carto.analyticstoolbox.spark.sql.rules.SpatialFilterPushdownRules

val spark: SparkSession = ???
SpatialFilterPushdownRules.registerOptimizations(sparkContext.sqlContext)
```

It is also possible to set it through the Spark configuration via the optimizations injector:

```scala
import com.carto.analyticstoolbox.spark.sql.SpatialFilterPushdownOptimizations

val conf: SparkConfig = ???
config.set("spark.sql.extensions", classOf[SpatialFilterPushdownOptimizations].getName)
```

In case there is a need to have optimizations enabled on a DataBricks cluster by default, follow [Enabling CARTO Query Optimizations on Databricks](#enabling-carto-query-optimizations-on-databricks) section.

## Table Optimization

There are two functions defined to help with the raw table preparations. Both transform the input table 
into a shape optimized for intersection queries; for more details see [OptimizeSpatial.scala](./libraries/scala/core/src/main/scala/com/carto/analyticstoolbox/spark/spatial/OptimizeSpatial.scala):

1. **optimizeSpatial**
   * Uses heuristics to compute the optimal parquet block size
2. **optimizeSpatialManual**
   * Uses the user input to set the output parquet file block size

```scala
import com.carto.analyticstoolbox.spark.spatial._

val sourceTable: String = ???
val outputTable: String = ???
val outputLocation: String = ???

// optimize with the block size computation 
spark.optimizeSpatial(sourceTable, outputTable, outputLocation, geomColumn = "bbox")
// optimize with the user defined block size
spark.optimizeSpatialManual(sourceTable, outputTable, outputLocation, geomColumn = "bbox", blockSize = 20097000)
```

### Enabling CARTO Query Optimizations on Databricks

> This section and approach are based on [docs](https://sedona.apache.org/setup/databricks/)
> from Apache Sedona.

#### Create Initialization Script

First, write a script to DBFS which can be used to copy jars from
[DBFS](https://docs.databricks.com/data/databricks-file-system.html) to
[the default class path](https://kb.databricks.com/libraries/replace-default-jar-new-jar.html)
cluster directory on master.

These scripts can be written using notebook cells:

```bash
%sh 
rm -rf /dbfs/FileStore/jars-carto

# Create JAR directory for CARTO Analytics Toolbox
mkdir -p /dbfs/FileStore/jars-carto/

# Download assembly har from GitHub into DBFS
curl -L -o /dbfs/FileStore/jars-carto/core-assembly-{version}.jar "https://github.com/CartoDB/analytics-toolbox-databricks/releases/download/v{version}/core-assembly-{version}.jar"
```

```bash
%sh 
rm -rf /dbfs/FileStore/carto/

# Create JAR directory for CARTO
mkdir -p /dbfs/FileStore/carto/

# Create init script
cat > /dbfs/FileStore/carto/carto-init.sh <<'EOF'
#!/bin/bash
#
# 
# On cluster startup, this script will copy the CARTO jars to the cluster's default jar directory.
# In order to activate CARTO Spatial optimizations: "com.carto.analyticstoolbox.spark.sql.rules.SpatialFilterPushdownRules"

cp /dbfs/FileStore/jars-carto/core-assembly-{version}.jar /databricks/jars

EOF
```

Where `/dbfs/FileStore/jars-carto/core-assembly-{version}.jar` is a path to the installed CARTO Analytics Toolbox
package of a certain version.

#### Update Cluster Configuration

Next, we need to update the spark config and inform the cluster of its new initialization script.
Navigate to cluster settings and find the 'Advanced options'. From your cluster configuration
activate the CARTO Spatial optimizations by adding to the Spark Config
(`Cluster` -> `Edit` -> `Configuration` -> `Advanced options` -> `Spark`).

To the spark config, add
```cfg
spark.sql.extensions com.carto.analyticstoolbox.spark.sql.SpatialFilterPushdownOptimizations
```

This will inform spark of the class which will register sql extensions. Move from the `Spark` tab
of advanced options to the `Init scripts` tab and add an entry for the initialization script
written above (`dbfs:/FileStore/carto/carto-init.sh`).

Restart the cluster and predicate pushdown for spatial intersection is enabled,
allowing certain workflows to run far more efficiently.

#### Why is this necessary?

The startup of a databricks cluster looks something like:

1. The JVM process starts with the cluster default classpath
2. The Spark config is initialized (Here's where we want to enable optimizations)
3. [VFS](https://commons.apache.org/proper/commons-vfs/) / [DBFS](https://docs.databricks.com/data/databricks-file-system.html) user class paths are mounted

The jar which contains classes that are referenced in step 2 isn't available prior to step 3!
Fortunately, it is possible to set up Databricks
[initialization scripts](https://docs.databricks.com/clusters/init-scripts.html)
which run prior to step 1 and which we can use on databricks to ensure our classes are
available by the time a cluster loads its spark config.
