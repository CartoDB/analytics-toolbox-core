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

package com.carto.analyticstoolbox.modules.accessors

import com.azavea.hiveless.HUDTF
import org.apache.spark.unsafe.types.UTF8String
import org.locationtech.geomesa.spark.jts.udf.GeometricConstructorFunctions
import org.locationtech.jts.geom.Geometry

import java.{lang => jl}
import scala.util.{Success, Try}

class ST_IsGeomField extends HUDTF[Boolean] {
  val circularInspectors: Boolean = true

  def eval(arguments: Array[AnyRef]): Array[AnyRef] = arguments.map {
    case _: Geometry => jl.Boolean.TRUE
    case s: UTF8String =>
      Try(GeometricConstructorFunctions.ST_GeomFromWKT(s.toString)) match {
        case Success(_) => jl.Boolean.TRUE
        case _          => jl.Boolean.FALSE
      }
    case _ => jl.Boolean.FALSE
  }
}
