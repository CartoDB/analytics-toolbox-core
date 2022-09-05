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

package com.carto.hiveless.spatial.util

import org.locationtech.jts.geom.Geometry

trait TWKBUtils {

  private[this] val readerPool = new ThreadLocal[TWKBReader] {
    override def initialValue = new TWKBReader
  }

  private[this] val writerPool = new ThreadLocal[TWKBWriter] {
    override def initialValue = new TWKBWriter
  }

  def read(s: String): Geometry      = read(s.getBytes)
  def read(b: Array[Byte]): Geometry = readerPool.get.read(b)

  def write(g: Geometry): Array[Byte] = writerPool.get.write(g)
}

object TWKBUtils extends TWKBUtils
