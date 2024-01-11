const { runQuery } = require('../../../common/test-utils');

test('ST_TILEENVELOPE should work', async () => {
    const query = `
        SELECT ST_TILEENVELOPE(10, 384, 368) as geog1,
               ST_TILEENVELOPE(18, 98304, 94299) as geog2,
               ST_TILEENVELOPE(25, 12582912, 12070369) as geog3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].GEOG1)).toEqual('{"coordinates":[[[-44.648437499999986,45.089035564831015],[-44.648437499999986,44.84029065139799],[-45,44.84029065139799],[-45,45.089035564831015],[-44.648437499999986,45.089035564831015]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0].GEOG2)).toEqual('{"coordinates":[[[-44.998626708984375,45.00073807829067],[-44.998626708984375,44.999767019181284],[-45,44.999767019181284],[-45,45.00073807829067],[-44.998626708984375,45.00073807829067]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0].GEOG3)).toEqual('{"coordinates":[[[-44.99998927116395,45.000002199069606],[-44.99998927116395,44.99999461263666],[-45,44.99999461263666],[-45,45.000002199069606],[-44.99998927116395,45.000002199069606]]],"type":"Polygon"}');
});

test('ST_TILEENVELOPE should return NULL if any NULL argument', async () => {
    const query = `
        SELECT ST_TILEENVELOPE(10, 384, null) as geog
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].GEOG).toEqual(null);
});