package com.carto.analyticstoolbox.modules.index

import com.azavea.hiveless.HUDF
import com.carto.analyticstoolbox.modules._
import com.azavea.hiveless.implicits.tupler._
import geotrellis.layer.{SpatialKey, ZoomedLayoutScheme}
import geotrellis.proj4.{CRS, LatLng}
import geotrellis.store.index.zcurve.Z2
import geotrellis.vector._

class ST_PartitionCentroid extends HUDF[(Geometry, Int, Option[Int], Option[Int], Option[CRS], Option[Double]), Long] {
  def function: ((Geometry, Int, Option[Int], Option[Int], Option[CRS], Option[Double])) => Long = ST_PartitionCentroid.function
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
