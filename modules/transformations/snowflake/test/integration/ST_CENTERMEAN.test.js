const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_CENTERMEAN should work', async () => {
    const query = `SELECT ST_CENTERMEAN(TO_GEOGRAPHY('POLYGON ((4.77802276611328 45.7784187892391, 4.77338790893555 45.7402141789073, 4.82419967651367 45.713371483331, 4.89492416381836 45.7271539426975, 4.91037368774414 45.7608167797245, 4.88239288330078 45.792544274359, 4.82505798339844 45.7939805638674, 4.77802276611328 45.7784187892391))')) as centerMean1,
    ST_CENTERMEAN(TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))')) as centerMean2,
    ST_CENTERMEAN(TO_GEOGRAPHY('POLYGON ((-120 30, -90 40, 20 40, -45 -20, -120 30))')) as centerMean3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].CENTERMEAN1)).toEqual('{"coordinates":[4.833297729492188,45.76061485017061],"type":"Point"}');
    expect(JSON.stringify(rows[0].CENTERMEAN2)).toEqual('{"coordinates":[26,24],"type":"Point"}');
    expect(JSON.stringify(rows[0].CENTERMEAN3)).toEqual('{"coordinates":[-71,24],"type":"Point"}');
});

test('ST_CENTERMEAN should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT ST_CENTERMEAN(NULL) as centerMean1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].CENTERMEAN1).toEqual(null);
});