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

package com.carto.analyticstoolbox.modules.constructors

import com.carto.analyticstoolbox.{HiveTestEnvironment, TestTables}
import org.apache.spark.sql.Row
import org.scalatest.funspec.AnyFunSpec

class STConstructorsSpec extends AnyFunSpec with HiveTestEnvironment with TestTables {
  describe("ST constructors functions spec") {
    it("ST_POINT can be created from the result of ST_X and ST_Y") {
      val df = ssc.sql(
        """WITH t AS(
          |  SELECT ST_POINT(1.5, 2.5) as point
          |)
          |SELECT ST_ASTEXT(ST_POINT(ST_X(point), ST_Y(point))) FROM t""".stripMargin
      )
      val result: Array[Row] =  df.take(1)
      result.head.get(0) shouldEqual "POINT (1.5 2.5)"
    }
  }
}
