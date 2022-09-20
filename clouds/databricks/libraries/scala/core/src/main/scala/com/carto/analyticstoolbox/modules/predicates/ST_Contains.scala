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

package com.carto.analyticstoolbox.modules.predicates

import com.azavea.hiveless.HUDF
import com.carto.analyticstoolbox.modules.index._
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
