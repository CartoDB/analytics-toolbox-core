// import accessors from '../src/accessors';
// import constructors from '../src/constructors';
// import measurements from '../src/measurements';
// import quadkey from '../src/quadkey';
// import s2 from '../src/s2';
// import processing from '../src/processing';
// import transformations from '../src/transformations';
// import h3 from '../src/h3';
// import placekey from '../src/placekey';
// import clustering from '../src/clustering';
// import random from '../src/random';

// export default {
//     accessors,
//     constructors,
//     measurements,
//     quadkey,
//     s2,
//     processing,
//     transformations,
//     h3,
//     placekey,
//     clustering,
//     random
// };

const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

// [https://gist.github.com/1020396] by [https://github.com/atk]
function atob (input) {
    const str = String(input).replace(/[=]+$/, '') // #31: ExtendScript bad parse of /=
    if (str.length % 4 === 1) {
        throw new Error('\'atob\' failed: The string to be decoded is not correctly encoded.')
    }
    for (
    // initialize result and counters
        var bc = 0, bs, buffer, idx = 0, output = '';
    // get next character
        (buffer = str.charAt(idx++));
    // character found in table? initialize bit storage and add its ascii value;
        ~buffer && (bs = bc % 4 ? bs * 64 + buffer : buffer,
        // and if not first of each 4 characters,
        // convert the first 8 bits to one ascii character
        bc++ % 4) ? output += String.fromCharCode(255 & bs >> (-2 * bc & 6)) : 0
    ) {
    // try to find character in table (0-63, not found => -1)
        buffer = chars.indexOf(buffer)
    }
    return output
}

import { VectorTile } from '@mapbox/vector-tile'
import { ungzip } from 'pako'
import Protobuf from 'pbf'

function extractProperties(prop, data) {
    const buffer = Uint8Array.from(atob(data), c => c.charCodeAt(0))
    const output = ungzip(buffer)
    const tile = new VectorTile(new Protobuf(output))
    const layer = tile.layers.default
    const properties = []
    for (let i = 0; i < layer._features.length; i++) {
        const feature = layer.feature(i)
        if (feature?.properties?.[prop] !== undefined) {
            properties.push(feature.properties[prop])
        }
    }
    return properties
}

export default {
    extractProperties
}
