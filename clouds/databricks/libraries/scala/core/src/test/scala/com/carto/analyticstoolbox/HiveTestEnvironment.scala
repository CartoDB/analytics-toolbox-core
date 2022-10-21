/*
 * Copyright 2022 Azavea
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.carto.analyticstoolbox

import com.carto.analyticstoolbox.spark.sql.rules.SpatialFilterPushdownRules
import geotrellis.spark.testkit.TestEnvironment
import org.apache.spark.SparkConf
import org.apache.spark.serializer.KryoSerializer
import org.apache.spark.sql.{SQLContext, SparkSession}
import org.scalatest.{BeforeAndAfterAll, Suite}

import java.io.File
import scala.io.Source
import scala.util.Properties

trait HiveTestEnvironment extends TestEnvironment { self: Suite with BeforeAndAfterAll =>
  import HiveTestEnvironment._

  def loadSQL(path: String): List[String] = {
    // Functions with SQL definitions cannot be defined in Spark SQL
    // so we will filter them out.
    val sparkFunction = """(?i)\ACREATE\s+OR\s+REPLACE\s+FUNCTION\s+[^\(]+\s+AS\s+\'.+"""
    Source
      .fromFile(new File(path).toURI)
      .using(_.mkString.split(";").toList.map(_.trim).filter(_.nonEmpty).filter(_ matches sparkFunction))
  }

  def spatialFunctions: List[String] = loadSQL("../core/src/main/resources/sql/modules.sql")

  // function to override Hive SQL functions registration
  def registerHiveUDFs(ssc: SparkSession): Unit =
    spatialFunctions.foreach(ssc.sql)

  // function to override optimizations
  def registerOptimizations(sqlContext: SQLContext): Unit =
    SpatialFilterPushdownRules.registerOptimizations(sqlContext)

  def addSparkConfigProperties(config: SparkConf): Unit = {}

  // returns (warehouseDir, derbyConnectionURL)
  def warehouseLocation: (String, String) = {
    val tmpDir = System.getProperty("java.io.tmpdir")
    // a separate warehouse for each spec, JDK 8 is unhappy with the old directory being populated
    val wdir          = s"${tmpDir}/cartoanalyticstoolbox-warehouse/${self.getClass.getName}"
    val ddir          = s"${tmpDir}/cartoanalyticstoolbox-db/${self.getClass.getName}"
    val connectionURL = s"jdbc:derby:;databaseName=${ddir};create=true"
    (wdir, connectionURL)
  }

  lazy val sparkConfig: SparkConf = {
    val (warehouseDir, derbyConnectionURL) = warehouseLocation
    val conf                               = new SparkConf()
    conf
      .setMaster(sparkMaster)
      .setAppName("Test Hive Context")
      .set("spark.default.parallelism", "4")
      // Since Spark 3.2.0 this flag is set to true by default
      // We need it to be set to false, since it is required by the HBase TableInputFormat
      .set("spark.hadoopRDD.ignoreEmptySplits", "false")
      .set("spark.sql.warehouse.dir", warehouseDir)
      .set("javax.jdo.option.ConnectionURL", derbyConnectionURL)

    // Shortcut out of using Kryo serialization if we want to test against
    // java serialization.
    if (Properties.envOrNone("GEOTRELLIS_USE_JAVA_SER").isEmpty) {
      conf
        .set("spark.serializer", classOf[KryoSerializer].getName)
        .set("spark.kryoserializer.buffer.max", "500m")
        .set("spark.kryo.registrationRequired", "false")
      setKryoRegistrator(conf)
    }

    addSparkConfigProperties(conf)
    conf
  }

  // override the SparkSession construction to enable Hive support
  override lazy val _ssc: SparkSession = {
    System.setProperty("spark.driver.port", "0")
    System.setProperty("spark.hostPort", "0")
    System.setProperty("spark.ui.enabled", "false")

    val sparkContext =
      SparkSession
        .builder()
        .config(sparkConfig)
        .enableHiveSupport()
        .getOrCreate()

    System.clearProperty("spark.driver.port")
    System.clearProperty("spark.hostPort")
    System.clearProperty("spark.ui.enabled")

    registerOptimizations(sparkContext.sqlContext)
    registerHiveUDFs(sparkContext)

    sparkContext
  }
}

object HiveTestEnvironment {
  implicit class AutoCloseableOps[A <: AutoCloseable](val resource: A) extends AnyVal {
    def using[B](f: A => B): B = try f(resource)
    finally resource.close()
  }
}
