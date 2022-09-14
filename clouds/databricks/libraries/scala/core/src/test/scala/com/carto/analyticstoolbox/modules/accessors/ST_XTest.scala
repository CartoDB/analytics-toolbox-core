package com.carto.analyticstoolbox.modules.accessors

import org.locationtech.jts.geom.{Coordinate, GeometryFactory, Point}
import org.scalatest.funspec.AnyFunSpec
import org.scalatest.matchers.should.Matchers._

class ST_XTest extends AnyFunSpec {
  def createPoint(coordinate: Coordinate): Point = {
    new GeometryFactory().createPoint(coordinate)
  }
  describe("ST_X") {
    it ("Should get the X from a point") {
      new ST_X().function(createPoint(new Coordinate(50, 100))) shouldEqual 50
    }

    it ("Should get 0 from an empty point") {
      new ST_X().function(createPoint(new Coordinate())) shouldEqual 0
    }
  }
}
