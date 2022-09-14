package com.carto.analyticstoolbox.modules.index

import org.scalatest.funspec.AnyFunSpec
import org.scalatest.matchers.should.Matchers.convertToAnyShouldWrapper

class ST_CrsFromTextTest extends AnyFunSpec {
  describe("ST_CrsFromText") {
    it ("Should return a CRS") {
      val crs = new ST_CrsFromText().function("+proj=merc +lat_ts=56.5 +ellps=GRS80")
      crs.proj4jCrs.getName shouldEqual "merc-CS"
    }
  }
}
