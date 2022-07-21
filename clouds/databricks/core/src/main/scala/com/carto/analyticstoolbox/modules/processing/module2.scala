package com.carto.analyticstoolbox.modules

import cats.Id
import com.azavea.hiveless.serializers.syntax.{ArrayDeferredObjectOps, ConverterOps}
import com.azavea.hiveless.serializers.{HConverter, HDeserializer, HSerializer}
import com.azavea.hiveless.spatial.util.TWKBUtils
import org.apache.spark.sql.types.{BinaryType, DataType}
import org.locationtech.jts.geom.Geometry

package object module2 extends Serializable {
  implicit def geometryConverter[T <: Geometry]: HConverter[T] = new HConverter[T] {
    def convert(argument: Any): T = TWKBUtils.read(argument.asInstanceOf[Array[Byte]]).asInstanceOf[T]
  }

  implicit def geometryUnaryDeserializer[T <: Geometry : HConverter]: HDeserializer[Id, T] =
    (arguments, inspectors) => arguments.deserialize[Array[Byte]](inspectors).convert[T]

  implicit def geometrySerializer[T <: Geometry]: HSerializer[T] = new HSerializer[T] {
    def dataType: DataType = BinaryType

    def serialize: Geometry => Array[Byte] = TWKBUtils.write
  }
}
