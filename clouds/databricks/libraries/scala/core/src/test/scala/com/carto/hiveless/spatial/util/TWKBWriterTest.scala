package com.carto.hiveless.spatial.util

import org.locationtech.geomesa.spark.jts.udf.GeometricConstructorFunctions
import org.locationtech.jts.geom.Geometry
import org.scalatest.funspec.AnyFunSpec

import java.lang

class TWKBWriterTest extends AnyFunSpec {
  describe("TWKBWriter") {
    it("TWKB utils should write and read the z") {

      val geom: Geometry             = GeometricConstructorFunctions.ST_MakePoint(1, 1)
      val bts                        = TWKBUtils.write(geom)
      val geomDeserialized: Geometry = TWKBUtils.read(bts)
      assert(lang.Double.isNaN(geomDeserialized.getCoordinate.z))
    }
  }
}
