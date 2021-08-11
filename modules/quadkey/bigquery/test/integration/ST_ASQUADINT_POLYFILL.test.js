const { runQuery } = require('../../../../../common/bigquery/test-utils');

const polyfillFixturesOut = require('./st_asquadint_polyfill_fixtures/out/polyfill');

test('ST_ASQUADINT_POLYFILL should work', async () => {
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

    const query = `
        SELECT
            \`@@BQ_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL\`(ST_GEOGFROMGEOJSON('${featureJSON}'), 10) as polyfill10,
            \`@@BQ_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL\`(ST_GEOGFROMGEOJSON('${featureJSON}'), 14) as polyfill14`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);  
    expect(rows[0].polyfill10.sort()).toEqual(polyfillFixturesOut.polyfill1);
    expect(rows[0].polyfill14.sort()).toEqual(polyfillFixturesOut.polyfill2);
});

test('ST_ASQUADINT_POLYFILL should work with GEOMETRYCOLLECTION', async () => {
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

    const query = `SELECT \`@@BQ_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL\`(ST_GEOGFROMGEOJSON('${featureJSON}'), 22) as polyfill22`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].polyfill22.sort()).toEqual(polyfillFixturesOut.polyfill3);
});

test('ST_ASQUADINT_POLYFILL should fail if any NULL argument', async () => {
    let query = 'SELECT `@@BQ_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL`(NULL, 10);';
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

    query = `SELECT \`@@BQ_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL\`(ST_GEOGFROMGEOJSON('${featureJSON}'), NULL)`;
    await expect(runQuery(query)).rejects.toThrow();
});