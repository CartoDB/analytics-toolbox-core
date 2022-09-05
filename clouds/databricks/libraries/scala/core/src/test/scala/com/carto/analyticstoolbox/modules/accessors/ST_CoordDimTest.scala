package com.carto.analyticstoolbox.modules.accessors

import com.carto.hiveless.spatial.util.TWKBUtils
import org.locationtech.geomesa.spark.jts.udf.{GeometricConstructorFunctions, GeometricOutputFunctions}
import org.locationtech.jts.geom.{Coordinate, CoordinateXY, Geometry, GeometryFactory, Point}
import org.scalatest.funspec.AnyFunSpec
import org.scalatest.matchers.should.Matchers.convertToAnyShouldWrapper

import java.lang
import scala.Double.NaN

class ST_CoordDimTest extends AnyFunSpec {
  describe("ST_CoordDim") {
    it ("Should get 3 for 3D points") {
      new ST_CoordDim().function(GeometricConstructorFunctions.ST_MakePointM(1, 2, 3)) shouldEqual 3
    }

    it ("Should get 2 for 2D lines") {
      new ST_CoordDim().function(GeometricConstructorFunctions.ST_GeomFromWKT("LINESTRING (0 0, 1 2, 2 3)")) shouldEqual 2
    }

    it ("Should get 3 for 3D lines") {
      new ST_CoordDim().function(GeometricConstructorFunctions.ST_GeomFromWKT("LINESTRING (0 0, 1 2, 2 3 1)")) shouldEqual 3
    }

    it ("Should get 2 for 2D points") {
      new ST_CoordDim().function(GeometricConstructorFunctions.ST_MakePoint(1, 2)) shouldEqual 2
    }

    it ("TWKB utils should write and read the z") {
      val geom: Geometry = GeometricConstructorFunctions.ST_MakePoint(1, 1)
      val bts = TWKBUtils.write(geom)
      val geomDeserialized: Geometry = TWKBUtils.read(bts)
      assert(lang.Double.isNaN(geomDeserialized.getCoordinate.z))
    }
  }
}
