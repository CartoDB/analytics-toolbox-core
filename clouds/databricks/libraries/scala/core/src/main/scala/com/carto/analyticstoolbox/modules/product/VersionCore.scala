/*
 * Copyright 2022 CARTO
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

package com.carto.analyticstoolbox.modules.product

import AT_core.BuildInfo
import com.azavea.hiveless.HGenericUDF
import com.azavea.hiveless.serializers.HSerializer
import org.apache.hadoop.hive.ql.udf.generic.GenericUDF
import org.apache.spark.sql.types.DataType

abstract class HUDFNOARGS[R](implicit s: HSerializer[R]) extends HGenericUDF[R] {
  def name: String        = this.getClass.getName.split("\\.").last
  def dataType: DataType  = s.dataType
  def serialize: R => Any = s.serialize
  def function: () => R

  def eval(arguments: Array[GenericUDF.DeferredObject]): R = function()
}

class VersionCore extends HUDFNOARGS[String] {
  // FIXME: use a date version as in other clouds.
  def function: () => String = () => BuildInfo.version
}
