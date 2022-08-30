package com.carto.analyticstoolbox.modules

import cats.Id
import com.azavea.hiveless.serializers.syntax.{ArrayDeferredObjectOps, ConverterOps, SerializerOps}
import com.azavea.hiveless.serializers.{HConverter, HDeserializer, HSerializer}
import com.azavea.hiveless.spark.encoders.syntax.{CachedExpressionOps, CachedInternalRowOps}
import com.carto.analyticstoolbox.spark.geotrellis.Z2Index
import com.carto.analyticstoolbox.spark.geotrellis.encoders.StandardEncoders
import geotrellis.proj4.CRS
import geotrellis.vector.Extent
import org.apache.spark.sql.catalyst.InternalRow
import org.apache.spark.sql.types.{DataType, StringType}

package object index extends StandardEncoders {
  implicit def crsConverter: HConverter[CRS] = new HConverter[CRS] {
    def convert(argument: Any): CRS = CRS.fromString(argument.convert[String])
  }

  implicit def extentConverter: HConverter[Extent] = new HConverter[Extent] {
    def convert(argument: Any): Extent = argument.convert[InternalRow].as[Extent]
  }

  implicit def crsUnaryDeserializer: HDeserializer[Id, CRS] =
    (arguments, inspectors) => arguments.deserialize[String](inspectors).convert[CRS]

  implicit def crsSerializer: HSerializer[CRS] = new HSerializer[CRS] {
    def dataType: DataType = StringType

    def serialize: CRS => Any = crs => crs.toProj4String.serialize
  }

  /** HSerializer.expressionEncoderSerializer is not used since TypeTags are not Kryo serializable by default. */
  implicit def extentSerializer: HSerializer[Extent] = new HSerializer[Extent] {
    def dataType: DataType = extentEncoder.schema

    def serialize: Extent => InternalRow = _.toInternalRow
  }

  implicit def z2IndexSerializer: HSerializer[Z2Index] = new HSerializer[Z2Index] {
    def dataType: DataType = z2IndexEncoder.schema

    def serialize: Z2Index => InternalRow = _.toInternalRow
  }

  /** UnaryDeserializer.expressionEncoderUnaryDeserializer since TypeTags are not Kryo serializable by default. */
  implicit def extentUnaryDeserializer: HDeserializer[Id, Extent] =
    (arguments, inspectors) => arguments.deserialize[InternalRow](inspectors).as[Extent]
}
