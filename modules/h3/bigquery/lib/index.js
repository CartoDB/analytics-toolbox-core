const { geoToH3 } = require('h3-js');

module.exports.h3 = {
    geoToH3,
    version() {
        return require('../package.json').version;
    }
};

// module.exports.h3 = {
//     geoToH3,
//     version() {
//         return '1234'
//     }
// };

// import { geoToH3 } from '../node_modules/h3-js/dist/h3-js.js';

// export default {
//     geoToH3,
//     version() {
//         return '1234'
//     }
// }