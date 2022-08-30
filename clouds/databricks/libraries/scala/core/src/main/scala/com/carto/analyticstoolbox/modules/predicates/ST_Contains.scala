package com.carto.analyticstoolbox.modules.predicates

import com.azavea.hiveless.HUDF
import com.carto.analyticstoolbox.index._
import com.carto.analyticstoolbox.modules._
import com.azavea.hiveless.implicits.tupler._
import com.carto.analyticstoolbox.modules.predicates.ST_Contains.Arg

class ST_Contains extends HUDF[(ST_Contains.Arg, ST_Contains.Arg), Boolean] {
  def function: ((Arg, Arg)) => Boolean = ST_Contains.function
}

object ST_Contains {
  type Arg = ST_Intersects.Arg

  def function(left: Arg, right: Arg): Boolean = {
    val (l, r) = (ST_Intersects.parseGeometryUnsafe(left, "first"), ST_Intersects.parseGeometryUnsafe(right, "second"))

    l.contains(r)
  }
}
