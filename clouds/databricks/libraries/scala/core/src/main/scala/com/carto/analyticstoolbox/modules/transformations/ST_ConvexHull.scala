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

package com.carto.analyticstoolbox.modules.transformations

import com.azavea.hiveless.{HAggregationBuffer, HGenericUDAFEvaluator}
import com.carto.analyticstoolbox.modules.{geometryConverter, geometrySerializer}
import org.apache.hadoop.hive.ql.udf.generic.{AbstractGenericUDAFResolver, GenericUDAFEvaluator}
import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo
import org.locationtech.jts.geom.Geometry

class ST_ConvexHull extends AbstractGenericUDAFResolver {
  implicit def geometryConvexHullBuffer: HAggregationBuffer[Geometry] = new HAggregationBuffer[Geometry] {
    protected var accumulator: Geometry = _

    def add(argument: Geometry): Unit =
      if (argument != null)
        if (accumulator == null) accumulator = argument.convexHull()
        // convexHull of the argument to avoid collecting union into the Geometry Collection
        else accumulator = accumulator.union(argument.convexHull()).convexHull()

    def reset: Unit = accumulator = null
  }

  override def getEvaluator(info: Array[TypeInfo]): GenericUDAFEvaluator = HGenericUDAFEvaluator[Geometry]
}
