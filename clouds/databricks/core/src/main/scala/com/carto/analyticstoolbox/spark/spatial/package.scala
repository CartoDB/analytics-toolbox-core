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

package com.carto.analyticstoolbox.spark

import org.apache.spark.sql.SparkSession

package object spatial extends Serializable {
  implicit class SparkSessionOps(val ssc: SparkSession) extends AnyVal {
    import OptimizeSpatial._

    def optimizeSpatial(
      sourceTable: String,
      outputTable: String,
      outputLocation: String = DEFAULT_OUTPUT_LOCATION,
      geomColumn: String = DEFAULT_GEOM_COLUMN,
      zoom: Int = DEFAULT_ZOOM,
      blockSizeDefault: Long = DEFAULT_BLOCK_SIZE,
      compression: String = DEFAULT_COMPRESSION,
      maxRecordsPerFile: Int = DEFAULT_MAX_RECORDS_PER_FILE
    ): Unit = OptimizeSpatial(sourceTable, outputTable, outputLocation, geomColumn, zoom, blockSizeDefault, compression, maxRecordsPerFile)(ssc)

    def optimizeSpatialManual(
      sourceTable: String,
      outputTable: String,
      outputLocation: String = DEFAULT_OUTPUT_LOCATION,
      geomColumn: String = DEFAULT_GEOM_COLUMN,
      zoom: Int = DEFAULT_ZOOM,
      blockSize: Long = DEFAULT_BLOCK_SIZE,
      compression: String = DEFAULT_COMPRESSION,
      maxRecordsPerFile: Int = DEFAULT_MAX_RECORDS_PER_FILE
    ): Unit = OptimizeSpatial(sourceTable, outputTable, outputLocation, geomColumn, zoom, _ => blockSize, compression, maxRecordsPerFile)(ssc)
  }
}
