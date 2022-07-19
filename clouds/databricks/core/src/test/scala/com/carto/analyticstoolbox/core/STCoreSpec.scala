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

package com.carto.analyticstoolbox.core

import com.carto.analyticstoolbox.{HiveTestEnvironment, TestTables}
import org.scalatest.funspec.AnyFunSpec

class STCoreSpec extends AnyFunSpec with HiveTestEnvironment with TestTables {
  describe("ST Core functions spec") {
    it("ST_Intersects should filter a CSV view") {
      val df = ssc.sql(
        """
          |SELECT * FROM polygons_csv_view WHERE ST_Intersects(geom, ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-75.5859375,40.32517767999294],[-75.5859375,43.197167282501276],[-72.41015625,43.197167282501276],[-72.41015625,40.32517767999294],[-75.5859375,40.32517767999294]]]}'))
          |""".stripMargin
      )

      df.count() shouldBe 5
    }
  }
}
