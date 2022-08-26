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

package com.carto.analyticstoolbox.spark.sql.rules

import com.carto.analyticstoolbox.modules._
import com.carto.analyticstoolbox.index._
import com.azavea.hiveless.spark.rules.syntax._
import com.azavea.hiveless.serializers.HDeserializer.Errors.ProductDeserializationError
import com.azavea.hiveless.serializers.syntax._
import geotrellis.vector._
import cats.syntax.option._
import com.carto.analyticstoolbox.modules.predicates.ST_Intersects
import org.apache.commons.lang3.exception.ExceptionUtils
import org.apache.spark.sql.hive.HivelessInternals.HiveGenericUDF
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.catalyst.plans.logical.{Filter, LogicalPlan}
import org.log4s.getLogger

import scala.util.{Failure, Success, Try}

object STIntersectsRule extends Serializable {
  @transient private[this] lazy val logger = getLogger

  def apply(f: Filter, condition: HiveGenericUDF, plan: LogicalPlan): Filter =
    try {
      val Seq(extentExpr, geometryExpr) = condition.children

      // ST_Intersects is polymorphic by the first argument
      // Optimization is done only when the first argument is Extent
      if (!extentExpr.dataType.conformsToSchema(extentEncoder.schema))
        throw new UnsupportedOperationException(
          s"${classOf[ST_Intersects]} push-down optimization works on the ${classOf[Extent]} column data type only."
        )

      // transform expression
      val expr = Try(geometryExpr.eval(null)) match {
        // Literals push-down support only
        case Success(g) =>
          // ST_Intersects is polymorphic by the second argument
          // Extract Extent literal from the right
          // The second argument can be Geometry or Extent
          val (extent, isGeometry) = Try(g.convert[Geometry].extent -> true)
            .orElse(Try(g.convert[Extent] -> false))
            .getOrElse(throw ProductDeserializationError[ST_Intersects, ST_Intersects.Arg]("second"))

          // transform expression
          val expanded =
            And(
              IsNotNull(extentExpr),
              OrList(
                List(
                  GreaterThanOrEqual(GetStructField(extentExpr, 0, "xmin".some), Literal(extent.xmin)),
                  GreaterThanOrEqual(GetStructField(extentExpr, 1, "ymin".some), Literal(extent.ymin)),
                  LessThanOrEqual(GetStructField(extentExpr, 2, "xmax".some), Literal(extent.xmax)),
                  LessThanOrEqual(GetStructField(extentExpr, 3, "ymax".some), Literal(extent.ymax))
                  // the old condition node is a secondary filter which is not pushed down
                  // it is needed in case it is a Geometry intersection
                )
              )
            )

          if (isGeometry) And(expanded, condition) else expanded
        // Expression
        case Failure(_) =>
          // In case on the right we have an Expression, no further optimizations needed and
          // such predicates won't be pushed down.
          //
          // In case Geometry is on the right, we can't extract Envelope coordinates, to perform it we need to define
          // User Defined Expression and that won't be pushed down.
          //
          // However, it is possible to extract coordinates out of Extent.
          // In this case the GetStructField can be used to extract values and transform the request,
          // though such predicates are not pushed down as well.
          //
          // The rough implementation of the idea above (The transformed plan for Extent, which is not pushed down):
          /*if (geometryExpr.dataType.conformsToSchema(extentEncoder.schema)) {
            And(
              IsNotNull(extentExpr),
              OrList(
                List(
                  GreaterThanOrEqual(GetStructField(extentExpr, 0, "xmin".some), GetStructField(geometryExpr, 0, "xmin".some)),
                  GreaterThanOrEqual(GetStructField(extentExpr, 1, "ymin".some), GetStructField(geometryExpr, 1, "ymin".some)),
                  LessThanOrEqual(GetStructField(extentExpr, 2, "xmax".some), GetStructField(geometryExpr, 2, "xmax".some)),
                  LessThanOrEqual(GetStructField(extentExpr, 3, "ymax".some), GetStructField(geometryExpr, 3, "ymax".some))
                  // the old condition node is a secondary filter which is not pushed down
                  // it is needed in case it is a Geometry intersection
                )
              )
            )
          } else {
            throw new UnsupportedOperationException(
              s"${classOf[Geometry]} Envelope values extraction is not supported by the internal ${classOf[Geometry]} representation.".stripMargin
            )
          }*/

          throw new UnsupportedOperationException(
            s"${classOf[ST_Intersects]} push-down optimization works with ${classOf[Geometry]} and ${classOf[Extent]} Literals only."
          )
      }

      Filter(expr, plan)
    } catch {
      // fallback to the unoptimized node if optimization failed
      case e: Throwable =>
        logger.warn(
          s"""
             |${this.getClass.getName} ${classOf[ST_Intersects]} optimization failed, using the original plan.
             |StackTrace: ${ExceptionUtils.getStackTrace(e)}
             |""".stripMargin
        )
        f
    }
}
