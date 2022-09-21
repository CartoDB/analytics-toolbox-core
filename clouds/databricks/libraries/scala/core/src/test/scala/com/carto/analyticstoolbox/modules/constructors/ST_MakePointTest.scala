package com.carto.analyticstoolbox.modules.constructors

import org.scalatest.funspec.AnyFunSpec
import org.scalatest.matchers.should.Matchers.convertToAnyShouldWrapper

class ST_MakePointTest extends AnyFunSpec {
  describe("ST_MakePoint") {
    it("Should create a point with coordinates correctly") {
      val point = new ST_MakePoint().function(2, 4)
      point.getX shouldEqual 2
      point.getY shouldEqual 4
    }
  }
}
