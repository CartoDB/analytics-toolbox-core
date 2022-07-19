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
import com.carto.analyticstoolbox.spark.geotrellis.Z2Index
import geotrellis.store.index.zcurve.Z2
import geotrellis.vector.Geometry

class ST_Z2LatLon extends HUDF[Geometry, Z2Index] {
  def function = ST_Z2LatLon.function
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
