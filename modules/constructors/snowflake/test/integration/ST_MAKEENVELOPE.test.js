const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_MAKEENVELOPE should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, 11.0, 11.0) as poly1,
               @@SF_PREFIX@@constructors.ST_MAKEENVELOPE(-179.0, 10.0, 179.0, 11.0) as poly2,
               @@SF_PREFIX@@constructors.ST_MAKEENVELOPE(179.0, 10.0, -179.0, 11.0) as poly3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].POLY1)).toEqual('{"coordinates":[[[10,10],[10,11],[11,11],[11,10],[10,10]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0].POLY2)).toEqual('{"coordinates":[[[-179,10],[-179,11],[179,11],[179,10],[-179,10]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0].POLY3)).toEqual('{"coordinates":[[[179,10],[179,11],[-179,11],[-179,10],[179,10]]],"type":"Polygon"}');
});

test('ST_MAKEENVELOPE should return NULL if any NULL argument', async () => {
    const query = `
        SELECT @@SF_PREFIX@@constructors.ST_MAKEENVELOPE(NULL, 10.0, 11.0, 11.0) as poly1,
               @@SF_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, NULL, 11.0, 11.0) as poly2,
               @@SF_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, NULL, 11.0) as poly3,
               @@SF_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, 11.0, NULL) as poly4
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].POLY1).toEqual(null);
    expect(rows[0].POLY2).toEqual(null);
    expect(rows[0].POLY3).toEqual(null);
    expect(rows[0].POLY4).toEqual(null);
});