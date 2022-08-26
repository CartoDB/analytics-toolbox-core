package com.carto.analyticstoolbox.modules.index

import org.apache.spark.unsafe.types.UTF8String
import org.scalatest.funspec.AnyFunSpec

class ST_CrsFromTextTest extends AnyFunSpec {
  describe("ST_CrsFromText") {
    it ("Should return a CRS") {
      val cls = new ST_CrsFromText().function("+proj=merc +lat_ts=56.5 +ellps=GRS80")
      print(cls)
    }
    it ("CRS string to utf8 string") {
      "a".asInstanceOf[UTF8String]     //esto falla
      UTF8String.fromString("+proj=merc +lat_ts=56.5 +ellps=GRS80")  //esto no
    }
  }
}
