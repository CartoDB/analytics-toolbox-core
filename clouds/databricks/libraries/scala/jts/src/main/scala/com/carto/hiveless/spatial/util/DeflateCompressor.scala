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

import java.io.ByteArrayOutputStream
import java.util.zip.{Deflater, Inflater}

object DeflateCompressor {
  def compress(data: Array[Byte], level: Int = Deflater.DEFAULT_COMPRESSION): Array[Byte] = {
    val deflater = new Deflater(level)
    // take into account extra 10 leading bytes header, in case of 0 compression level it is important
    val tmp = Array.ofDim[Byte](data.length + 10)
    deflater.setInput(data)
    deflater.finish()
    val compressedSize = deflater.deflate(tmp)
    deflater.end()
    val result = Array.ofDim[Byte](compressedSize)
    System.arraycopy(tmp, 0, result, 0, compressedSize)
    result
  }

  def decompress(data: Array[Byte]): Array[Byte] = {
    val inflater = new Inflater()
    inflater.setInput(data)

    val outputStream = new ByteArrayOutputStream(data.length)
    val buffer       = new Array[Byte](1024)
    while (!inflater.finished()) {
      val count = inflater.inflate(buffer)
      outputStream.write(buffer, 0, count)
    }

    outputStream.close()
    inflater.reset()
    inflater.end()

    outputStream.toByteArray
  }
}
