package com.carto.analyticstoolbox.modules.index

import com.azavea.hiveless.HUDF
import com.carto.analyticstoolbox.modules._
import com.carto.analyticstoolbox.spark.geotrellis.Z2Index
import geotrellis.store.index.zcurve.Z2
import geotrellis.vector.Geometry

class ST_Z2LatLon extends HUDF[Geometry, Z2Index] {
  def function: Geometry => Z2Index = ST_Z2LatLon.function
}

object ST_Z2LatLon {
  def function(geom: Geometry): Z2Index = {
    val env = geom.getEnvelopeInternal
    Z2Index(z2index(env.getMinX, env.getMinY), z2index(env.getMaxX, env.getMaxY))
  }
  def scaleLat(lat: Double): Int          = ((lat + 90) / 180 * (1 << 30)).toInt
  def scaleLong(lng: Double): Int         = ((lng + 180) / 360 * (1 << 30)).toInt
  def z2index(x: Double, y: Double): Long = Z2(scaleLong(x), scaleLat(y)).z
}
