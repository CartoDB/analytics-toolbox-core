/*
 * Copyright 2022 CARTO & Azavea
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

package com.carto.analyticstoolbox

import cats.Id
import com.azavea.hiveless.serializers.syntax.{ArrayDeferredObjectOps, ConverterOps}
import com.azavea.hiveless.serializers.{HConverter, HDeserializer, HSerializer}
import com.carto.hiveless.spatial.util.TWKBUtils
import org.apache.spark.sql.types.{BinaryType, DataType}
import org.locationtech.jts.geom.Geometry

package object modules {
  implicit def geometryConverter[T <: Geometry]: HConverter[T] = new HConverter[T] {
    def convert(argument: Any): T = TWKBUtils.read(argument.asInstanceOf[Array[Byte]]).asInstanceOf[T]
  }

  implicit def geometryUnaryDeserializer[T <: Geometry: HConverter]: HDeserializer[Id, T] =
    (arguments, inspectors) => arguments.deserialize[Array[Byte]](inspectors).convert[T]

  implicit def geometrySerializer[T <: Geometry]: HSerializer[T] = new HSerializer[T] {
    def dataType: DataType = BinaryType

    def serialize: Geometry => Array[Byte] = TWKBUtils.write
  }
}
