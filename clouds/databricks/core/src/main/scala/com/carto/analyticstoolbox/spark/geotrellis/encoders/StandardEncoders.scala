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

package com.carto.analyticstoolbox.spark.geotrellis.encoders

import com.carto.analyticstoolbox.spark.geotrellis.Z2Index
import geotrellis.vector.Extent
import org.apache.spark.sql.catalyst.encoders.ExpressionEncoder
import org.apache.spark.sql.types.{DataType, StructType}

import scala.reflect.runtime.universe.TypeTag

trait StandardEncoders extends Serializable {
  def expressionEncoder[T: TypeTag]: ExpressionEncoder[T] = ExpressionEncoder()

  implicit val extentEncoder: ExpressionEncoder[Extent]   = expressionEncoder
  implicit val z2IndexEncoder: ExpressionEncoder[Z2Index] = expressionEncoder
}

object StandardEncoders extends StandardEncoders
