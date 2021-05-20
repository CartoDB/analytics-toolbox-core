const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_GREATCIRCLE should work', async () => {
    const query = `SELECT @@SF_PREFIX@@transformations.ST_GREATCIRCLE(ST_POINT(0, 0), ST_POINT(0, 10), 11) as greatcircle1,
    @@SF_PREFIX@@transformations.ST_GREATCIRCLE(ST_POINT(-1.70325, 1.4167), ST_POINT(1.70325, -1.4167), 5) as greatcircle2,
    @@SF_PREFIX@@transformations.ST_GREATCIRCLE(ST_POINT(5, 5), ST_POINT(-5, -5), 9) as greatcircle3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].GREATCIRCLE1)).toEqual('{"coordinates":[[0,0],[0,1],[0,1.9999999999999996],[0,3.0000000000000004],[0,4],[0,4.999999999999999],[0,6],[0,7],[0,7.999999999999998],[0,9.000000000000002],[0,10]],"type":"LineString"}');
    expect(JSON.stringify(rows[0].GREATCIRCLE2)).toEqual('{"coordinates":[[-1.7032500000000002,1.4166999999999998],[-0.8514948107357666,0.7084282465414006],[0,0],[0.8514948107357666,-0.7084282465414006],[1.7032500000000002,-1.4166999999999998]],"type":"LineString"}');
    expect(JSON.stringify(rows[0].GREATCIRCLE3)).toEqual('{"coordinates":[[4.999999999999999,4.999999999999999],[3.7458253753562287,3.7520830815016724],[2.4952312784633994,2.5023786781263677],[1.2470204043859645,1.2514859293872385],[0,0],[-1.2470204043859645,-1.2514859293872385],[-2.4952312784633994,-2.5023786781263677],[-3.7458253753562287,-3.7520830815016724],[-4.999999999999999,-4.999999999999999]],"type":"LineString"}');
});

test('ST_GREATCIRCLE should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT @@SF_PREFIX@@transformations.ST_GREATCIRCLE(NULL, ST_POINT(-73.9385,40.6643), 20) as greatcircle1,
    @@SF_PREFIX@@transformations.ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), NULL, 20) as greatcircle2,
    @@SF_PREFIX@@transformations.ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643), NULL) as greatcircle3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].GREATCIRCLE1).toEqual(null);
    expect(rows[0].GREATCIRCLE2).toEqual(null);
    expect(rows[0].GREATCIRCLE3).toEqual(null);
});

test('ST_GREATCIRCLE default values should work', async () => {
    const query = `SELECT @@SF_PREFIX@@transformations.ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643), 100) as defaultValue,
    @@SF_PREFIX@@transformations.ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643)) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM1).toEqual(rows[0].DEFAULTVALUE);
});