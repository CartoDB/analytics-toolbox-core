package com.carto.analyticstoolbox.modules.predicates

import com.azavea.hiveless.HUDF
import com.azavea.hiveless.implicits.tupler._
import com.azavea.hiveless.serializers.HDeserializer.Errors.ProductDeserializationError
import com.carto.analyticstoolbox.modules.index._
import com.carto.analyticstoolbox.modules._
import com.carto.analyticstoolbox.modules.predicates.ST_Intersects.Arg
import geotrellis.vector.{Extent, Geometry}
import shapeless.{:+:, CNil}

class ST_Intersects extends HUDF[(ST_Intersects.Arg, ST_Intersects.Arg), Boolean] {
  def function: ((Arg, Arg)) => Boolean = ST_Intersects.function
}

object ST_Intersects {
  // We could use Either[Extent, Geometry], but Either has no safe fall back CNil
  // which may lead to derivation error messages rather than parsing
  type Arg = Extent :+: Geometry :+: CNil

  def parseGeometry(a: Arg): Option[Geometry] = a.select[Geometry].orElse(a.select[Extent].map(_.toPolygon()))

  def parseGeometryUnsafe(a: Arg, aname: String): Geometry =
    parseGeometry(a).getOrElse(throw ProductDeserializationError[ST_Intersects, Arg](aname))

  def function(left: Arg, right: Arg): Boolean = {
    val (l, r) = (parseGeometryUnsafe(left, "first"), parseGeometryUnsafe(right, "second"))

    l.intersects(r)
  }
}
