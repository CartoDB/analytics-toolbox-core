const { runQuery } = require('../../../common/test-utils');

test('ST_CENTERMEDIAN should work', async () => {
    const query = `SELECT ST_CENTERMEDIAN(TO_GEOGRAPHY('POLYGON ((4.77802276611328 45.7784187892391, 4.77338790893555 45.7402141789073, 4.82419967651367 45.713371483331, 4.89492416381836 45.7271539426975, 4.91037368774414 45.7608167797245, 4.88239288330078 45.792544274359, 4.82505798339844 45.7939805638674, 4.77802276611328 45.7784187892391))')) as centerMedian1,
    ST_CENTERMEDIAN(TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))')) as centerMedian2,
    ST_CENTERMEDIAN(TO_GEOGRAPHY('POLYGON ((-120 30, -90 40, 20 40, -45 -20, -120 30))')) as centerMedian3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].CENTERMEDIAN1)).toEqual('{"coordinates":[4.841194152832032,45.75807143030369],"type":"Point"}');
    expect(JSON.stringify(rows[0].CENTERMEDIAN2)).toEqual('{"coordinates":[25,27.5],"type":"Point"}');
    expect(JSON.stringify(rows[0].CENTERMEDIAN3)).toEqual('{"coordinates":[-58.75000000000001,22.5],"type":"Point"}');
});

test('ST_CENTERMEDIAN should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT ST_CENTERMEDIAN(NULL) as centerMedian1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].CENTERMEDIAN1).toEqual(null);
});