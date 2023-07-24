const { runQuery } = require('../../../common/test-utils');

const point = 'POINT(-3.7115216913662175 40.41092231814629)'
const multiPoint = 'MULTIPOINT ((-3.7115216913662175 40.41092231814629),(-3.7112427416286686 40.41200062990766),(-3.710985249563239 40.41080795073389))'
const line = 'LINESTRING(-3.7142468157253483 40.40915777072141,-3.712337082906745 40.41110203797309,-3.711178368612311 40.40969694289874,-3.709290093465827 40.411396123927084)'
const multiLine = 'MULTILINESTRING ((-3.7142468157253483 40.40915777072141,-3.712337082906745 40.41110203797309,-3.711178368612311 40.40969694289874,-3.709290093465827 40.411396123927084),(-3.7137572531829233 40.40860338576905,-3.7100021605620737 40.40893832932828))'
const polygon = 'POLYGON ((-3.71219873428345 40.413365349070865,-3.7144088745117 40.40965661286395,-3.70659828186035 40.409525904775634,-3.71219873428345 40.413365349070865))'
const multiPolygon = 'MULTIPOLYGON (((-3.7102890014648438 40.412768896581476,-3.7081432342529297 40.41124946964811,-3.707242012023926 40.41370014129302,-3.7102890014648438 40.412768896581476)),((-3.71219873428345 40.413365349070865,-3.7144088745117 40.40965661286395,-3.70659828186035 40.409525904775634,-3.71219873428345 40.413365349070865),(-3.7122470136178776 40.41158984452673,-3.710165619422321 40.41109970196702,-3.711882233191852 40.41018475963737,-3.7122470136178776 40.41158984452673)))'

test.each([
    ['Point', 9, point, '["89390cb1b4bffff"]'],
    ['MultiPoint', 9, multiPoint, '["89390cb1b4bffff"]'],
    ['MultiPoint', 10, multiPoint, '["8a390cb1b4a7fff","8a390cb1b4b7fff"]'],
    ['MultiPoint', 11, multiPoint, '["8b390cb1b486fff","8b390cb1b4b0fff","8b390cb1b4a6fff"]'],
    ['Line', 8, line, '["88390ca349fffff","88390cb1b5fffff"]'],
    ['Line', 9, line, '["89390ca3497ffff","89390cb1b4bffff"]'],
    ['Line', 10, line, '["8a390ca3496ffff","8a390ca34947fff","8a390cb1b4affff","8a390ca3494ffff","8a390cb1b4b7fff","8a390cb1b487fff","8a390ca3495ffff","8a390cb1b497fff"]'],
    ['MultiLine', 8, multiLine, '["88390ca349fffff","88390cb1b5fffff"]'],
    ['MultiLine', 9, multiLine, '["89390ca3487ffff","89390ca3497ffff","89390cb1b4bffff"]'],
    ['Polygon', 9, polygon, '["89390cb1b5bffff","89390ca34b3ffff","89390ca3487ffff","89390ca3497ffff","89390cb1b4bffff","89390cb1b4fffff"]'],
    ['MultiPolygon', 9, multiPolygon, '["89390cb1b5bffff","89390ca34b3ffff","89390ca3487ffff","89390cb1b43ffff","89390ca3497ffff","89390cb1b4bffff","89390cb1b4fffff"]']
])('H3_POLYFILL should work with %p at resolution %p', async (_, resolution, geom, output) => {
    const query = `SELECT TO_JSON_STRING(\`@@BQ_DATASET@@.H3_POLYFILL\`(
        ST_GEOGFROMTEXT('${geom}'), ${resolution})) AS output`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(output);
});

test.each([
    ['Point', 'intersects', 9, point, '["89390cb1b4bffff"]'],
    ['Point', 'contains', 9, point, 'null'],
    ['Point', 'center', 9, point, 'null'],
    ['Line', 'intersects', 8, line, '["88390ca349fffff","88390cb1b5fffff"]'],
    ['Line', 'contains', 8, line, 'null'],
    ['Line', 'center', 8, line, 'null'],
    ['Polygon', 'wrong-mode', 4, polygon, 'null'],
    ['Polygon', 'intersects', 9, polygon, '["89390cb1b5bffff","89390ca34b3ffff","89390ca3487ffff","89390ca3497ffff","89390cb1b4bffff","89390cb1b4fffff"]'],
    ['Polygon', 'contains', 10, polygon, '["8a390cb1b4b7fff","8a390cb1b487fff"]'],
    ['Polygon', 'center', 9, polygon, '["89390cb1b4bffff"]'],
    ['MultiPolygon', 'intersects', 9, multiPolygon, '["89390cb1b5bffff","89390ca34b3ffff","89390ca3487ffff","89390cb1b43ffff","89390ca3497ffff","89390cb1b4bffff","89390cb1b4fffff"]'],
    ['MultiPolygon', 'contains', 10, multiPolygon, 'null'],
    ['MultiPolygon', 'center', 9, multiPolygon, '["89390cb1b4bffff"]']

])('H3_POLYFILL_MODE should work with %p mode %p at resolution %p', async (_, mode, resolution, geom, output) => {
    const query = `SELECT TO_JSON_STRING(\`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(
        ST_GEOGFROMTEXT('${geom}'), ${resolution}, '${mode}')) AS output`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(output);
});