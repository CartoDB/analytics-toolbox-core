const { runQuery } = require('../../../../../common/snowflake/test-utils');

const polyfillFixturesOut = require('./st_asquadint_polyfill_fixtures/out/polyfill');


test('QUADINT_POLYFILL should work', async () => {
    const feature = {
        'type': 'Polygon',
        'coordinates': [
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
    const featureJSON = JSON.stringify(feature);

    const query = `SELECT QUADINT_POLYFILL(TO_GEOGRAPHY('${featureJSON}'), 10) as polyfill10,
    QUADINT_POLYFILL(TO_GEOGRAPHY('${featureJSON}'), 14) as polyfill14`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);  
    expect(rows[0]['POLYFILL10'].sort()).toEqual(['12631722', '12664490']);
    expect(rows[0]['POLYFILL10'].sort()).toEqual(polyfillFixturesOut.polyfill1);
    expect(rows[0]['POLYFILL14'].sort()).toEqual(['3237735182', '3238259438', '3238259470', '3238259502', '3238259534', '3238259566', '3238783694', '3238783726', '3238783758', '3238783790', '3238783822', '3238783854', '3239308014', '3239308046', '3239308078', '3239832270', '3239832302', '3239832334', '3239832366', '3239832398']);
    expect(rows[0]['POLYFILL14'].sort()).toEqual(polyfillFixturesOut.polyfill2);
});

test('QUADINT_POLYFILL should work with GEOMETRYCOLLECTION', async () => {
    const feature = {
        'type': 'GeometryCollection',
        'geometries': [ 
            {
                'type': 'LineString',
                'coordinates': [
                    [
                        -73.96697,
                        40.59585
                    ],
                    [
                        -73.96697,
                        40.59586
                    ]
                ]
            },
            {
                'type': 'LineString',
                'coordinates': [
                    [
                        -73.96697,
                        40.59585
                    ],
                    [
                        -73.96697,
                        40.59586
                    ]
                ]
            },
            { 
                'type': 'Polygon',
                'coordinates': [
                    [
                        [
                            -73.96697,
                            40.59585
                        ],
                        [
                            -73.96697,
                            40.59584
                        ],
                        [
                            -73.96733,
                            40.5958
                        ],
                        [
                            -73.96732,
                            40.59574
                        ],
                        [
                            -73.96695,
                            40.59578
                        ],
                        [
                            -73.96696,
                            40.5958
                        ],
                        [
                            -73.96697,
                            40.59585
                        ]
                    ]
                ]
            }
        ]
    };
    const featureJSON = JSON.stringify(feature);

    const query = `SELECT QUADINT_POLYFILL(TO_GEOGRAPHY('${featureJSON}'), 22) as polyfill22`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0]['POLYFILL22'].sort()).toEqual(polyfillFixturesOut.polyfill3);
});

test('QUADINT_POLYFILL should fail if any NULL argument', async () => {
    let query = 'SELECT QUADINT_POLYFILL(NULL, 10);';
    await expect(runQuery(query)).rejects.toThrow();

    const feature = {
        'type': 'Polygon',
        'coordinates': [
            [
                [
                    -3.6828231811523207,
                    40.45948689837198
                ],
                [
                    -3.6828231811523207,
                    40.45948689837198
                ]
            ]
        ]
    };
    const featureJSON = JSON.stringify(feature);

    query = `SELECT QUADINT_POLYFILL(TO_GEOGRAPHY('${featureJSON}'), NULL)`;
    await expect(runQuery(query)).rejects.toThrow();
});