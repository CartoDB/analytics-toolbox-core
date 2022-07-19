/*
 * Copyright 2021 Azavea
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

package com.carto.analyticstoolbox.core

import com.azavea.hiveless.HUDF
import com.azavea.hiveless.implicits.tupler._
import org.locationtech.geomesa.spark.jts.udf.GeometricOutputFunctions
import org.locationtech.jts.geom.Geometry

class ST_AsGeoHash extends HUDF[(Geometry, Int), String] {
  def function = GeometricOutputFunctions.ST_GeoHash
}
