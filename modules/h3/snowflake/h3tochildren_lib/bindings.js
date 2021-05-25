/*
 * Copyright 2018-2019 Uber Technologies, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Define the C bindings for the h3 library

// Add some aliases to make the function definitions more intelligible
const NUMBER = 'number';
const H3_LOWER = NUMBER;
const H3_UPPER = NUMBER;
const RESOLUTION = NUMBER;
const POINTER = NUMBER;

// Define the bindings to functions in the C lib. Functions are defined as
// [name, return type, [arg types]]. You must run `npm run build-emscripten`
// before new functions added here will be available.
export default [
    ['sizeOfH3Index', NUMBER],
    ['h3ToChildren', null, [H3_LOWER, H3_UPPER, RESOLUTION, POINTER]],
    ['maxH3ToChildrenSize', NUMBER, [H3_LOWER, H3_UPPER, RESOLUTION]]
];