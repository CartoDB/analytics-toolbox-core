const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../squelleton_library.js')+'');


let feature = {
    "type": "Polygon",
    "coordinates": [
      [
        [
          -3.6828231811523207,
          40.45948689837198
        ],
        [
          -3.69655609130857,
          40.42917828232078
        ],
        [
          -3.7346649169921777,
          40.42525806690142
        ],
        [
          -3.704452514648415,
          40.4090520858275
        ],
        [
          -3.7150955200195077,
          40.38212061782238
        ],
        [
          -3.6790466308593652,
          40.40251631173469
        ],
        [
          -3.6399078369140625,
          40.38212061782238
        ],
        [
          -3.6570739746093652,
          40.41245043754496
        ],
        [
          -3.6206817626953023,
          40.431791632323645
        ],
        [
          -3.66634368896482,
          40.42996229798495
        ],
        [
          -3.6828231811523207,
          40.45948689837198
        ]
      ]
    ]
};
var myBuff = turf.buffer(feature, 10,{'unit': 'kilometers', 'steps': 1});

console.log(myBuff);

return;
describe('SQUELLETON unit tests', () => {

    it ('Version', async () => {
        assert.equal(squelletonVersion(), '1.0.0');
    });

});
