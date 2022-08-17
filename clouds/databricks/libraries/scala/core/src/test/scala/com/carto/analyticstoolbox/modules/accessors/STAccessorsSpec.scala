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

package com.carto.analyticstoolbox.modules.accessors

import com.carto.analyticstoolbox.{HiveTestEnvironment, TestTables}
import org.scalatest.funspec.AnyFunSpec

class STAccessorsSpec extends AnyFunSpec with HiveTestEnvironment with TestTables {
  describe("ST accessors functions spec") {
    it("ST_COORDDIM test") {
      val df = ssc.sql(
        """SELECT ST_CoordDim(ST_Point(1,2))""".stripMargin
      )
      df.take(1).head.get(0) shouldEqual 2
    }
  }
}
