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

package com.carto.analyticstoolbox.modules.index

import com.carto.analyticstoolbox.{HiveTestEnvironment, TestTables}
import org.scalatest.funspec.AnyFunSpec

class STIndexSpec extends AnyFunSpec with HiveTestEnvironment with TestTables {
  describe("ST index functions spec") {
    it("ST_GEOMREPROJECT test") {
      val df = ssc.sql(
        """SELECT ST_ASTEXT(ST_GEOMREPROJECT(ST_POINT(3, 5),
          |ST_CRSFROMTEXT('+proj=merc +lat_ts=56.5 +ellps=GRS80'),
          |ST_CRSFROMTEXT('+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs')))""".stripMargin
      )
      df.head.get(0) shouldEqual "POINT (0.0000269 0.0000452)"
    }
  }
}
