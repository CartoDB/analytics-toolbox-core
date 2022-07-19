package com.carto.analyticstoolbox.core

import com.azavea.hiveless.HUDF
import org.locationtech.jts.geom.Geometry

class hudfTest extends HUDF[String, String] {
  override def function: String => String = _.split(":").mkString("Array(", ", ", ")")
}
