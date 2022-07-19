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

package com.carto.analyticstoolbox.index

import com.azavea.hiveless.HUDF
import com.carto.analyticstoolbox.core._
import com.azavea.hiveless.implicits.tupler._
import geotrellis.layer.{SpatialKey, ZoomedLayoutScheme}
import geotrellis.vector._
import geotrellis.proj4.{CRS, LatLng}
import geotrellis.store.index.zcurve.Z2

class ST_PartitionCentroid extends HUDF[(Geometry, Int, Option[Int], Option[Int], Option[CRS], Option[Double]), Long] {
  def function = ST_PartitionCentroid.function
}

object ST_PartitionCentroid {
  def function(
    geom: Geometry,
    zoom: Int,
    tileSizeOpt: Option[Int],
    bitsOpt: Option[Int],
    crsOpt: Option[CRS],
    resolutionThresholdOpt: Option[Double]
  ): Long = {
    val crs                 = crsOpt.getOrElse(LatLng)
    val tileSize            = tileSizeOpt.getOrElse(ZoomedLayoutScheme.DEFAULT_TILE_SIZE)
    val resolutionThreshold = resolutionThresholdOpt.getOrElse(ZoomedLayoutScheme.DEFAULT_RESOLUTION_THRESHOLD)
    val bits                = bitsOpt.getOrElse(8)

    val SpatialKey(col, row) = new ZoomedLayoutScheme(crs, tileSize, resolutionThreshold)
      .levelForZoom(zoom)
      .layout
      .mapTransform(geom.extent.center)

    Z2(col, row).z >> bits
  }
}
