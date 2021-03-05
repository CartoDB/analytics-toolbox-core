#!/usr/bin/env bash
set -ex

H3_JS_VERSION=${H3_JS_VERSION:-3.7.0}
H3_JS_LIBNAME=${H3_JS_LIBNAME:-h3-js.umd.js}

# Download the library
curl -L https://unpkg.com/h3-js@${H3_JS_VERSION}/dist/${H3_JS_LIBNAME} > ${H3_JS_LIBNAME}

# Download the associated tests
curl -L https://github.com/uber/h3-js/archive/v${H3_JS_VERSION}.zip > release.zip
unzip -o -j release.zip "h3-js-${H3_JS_VERSION}/test/h3core.spec.js" -d test/

# Replace the requirements in the spec file
sed -i test/h3core.spec.js \
    -e "s!import test from 'tape'!const test = require('tape')!g" \
    -e "s!import \* as h3 from '../lib/h3core.js'!const h3 = require('../h3-js.umd.js')!g"
rm release.zip
