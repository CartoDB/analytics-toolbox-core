package com.carto.analyticstoolbox.modules.dummy

import org.scalatest.funspec.AnyFunSpec
import org.scalatest.matchers.should.Matchers.convertToAnyShouldWrapper

class DummyFunctionTest extends AnyFunSpec {
  describe("Dummy_Function test") {
    it ("dummy test") {
      new DummyFunction().function("tree") shouldEqual "hello tree"
    }
  }

}
