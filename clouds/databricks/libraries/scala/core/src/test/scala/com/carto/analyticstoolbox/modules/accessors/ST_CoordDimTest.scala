package com.carto.analyticstoolbox.modules.accessors

import com.azavea.hiveless.spatial.util.TWKBUtils
import org.locationtech.geomesa.spark.jts.udf.{GeometricConstructorFunctions, GeometricOutputFunctions}
import org.locationtech.jts.geom.{Coordinate, Geometry, GeometryFactory, Point}
import org.scalatest.funspec.AnyFunSpec
import org.scalatest.matchers.should.Matchers.convertToAnyShouldWrapper

import scala.Double.NaN

class ST_CoordDimTest extends AnyFunSpec {
  describe("ST_CoordDim") {
    it ("Should get 3 for 3D points") {
      new ST_CoordDim().function(GeometricConstructorFunctions.ST_MakePointM(1, 2, 3)) shouldEqual 3
    }

    it ("Should get 2 for 2D points") {
      new ST_CoordDim().function(GeometricConstructorFunctions.ST_MakePoint(1, 2)) shouldEqual 2
    }

    it ("TWKB utils should write and read the z") {
      val geom: Geometry = GeometricConstructorFunctions.ST_MakePoint(1, 1)
      val bts = TWKBUtils.write(geom)
      val bts2 = GeometricOutputFunctions.ST_AsBinary(geom)
      val geomDeserialized: Geometry = TWKBUtils.read(bts)
      val geomDeserialized2: Geometry = GeometricConstructorFunctions.ST_GeomFromWKB(bts2)
      geomDeserialized2.getCoordinate.z shouldEqual geom.getCoordinate.z
      geomDeserialized.getCoordinate.z shouldEqual geom.getCoordinate.z
    }
  }
}
