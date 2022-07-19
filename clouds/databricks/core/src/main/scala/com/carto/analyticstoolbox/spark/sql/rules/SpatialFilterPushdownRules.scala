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

import com.carto.analyticstoolbox.core._
import com.azavea.hiveless.spark.rules.syntax._
import org.apache.spark.sql.hive.HivelessInternals.HiveGenericUDF
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.catalyst.plans.logical.{Filter, LogicalPlan}
import org.apache.spark.sql.catalyst.rules.Rule

object SpatialFilterPushdownRules extends Rule[LogicalPlan] {
  def apply(plan: LogicalPlan): LogicalPlan =
    // format: off
    /**
     * transform is an alias to transformDown
     * The transformDown usage causes the following error on DataBricks 9.1:
     *   java.lang.NoClassDefFoundError: LogicalPlan.transformDown(Lscala/PartialFunction;)Lorg/apache/spark/sql/catalyst/plans/logical/LogicalPlan;
     */
    // format: on
    plan.transform {
      case f @ Filter(condition: HiveGenericUDF, plan) if condition.of[ST_Intersects] => STIntersectsRule(f, condition, plan)
      case f @ Filter(condition: HiveGenericUDF, plan) if condition.of[ST_Contains]   => STContainsRule(f, condition, plan)
    }

  def registerOptimizations(sqlContext: SQLContext): Unit =
    Seq(SpatialFilterPushdownRules).foreach { r =>
      if (!sqlContext.experimental.extraOptimizations.contains(r))
        sqlContext.experimental.extraOptimizations ++= Seq(r)
    }
}
