const dissolveLib = require('../build/transformations_dissolve');

test('dissolve', () => {
    const geojson = {"coordinates":[[[[-122.29085146967267,37.83837888432099],[-122.29151850551112,37.8396507263405],[-122.2931289672852,37.84017754697746],[-122.29473942905928,37.8396507263405],[-122.29540646489774,37.83837888432099],[-122.2947393735248,37.83710706423049],[-122.2931289672852,37.83658026552255],[-122.29151856104559,37.83710706423049],[-122.29085146967267,37.83837888432099]]],[[[-122.28515226719908,37.83982846928078],[-122.28581931614504,37.84110031130087],[-122.28742980957031,37.841627131938395],[-122.28904030299559,37.84110031130087],[-122.28970735194154,37.83982846928078],[-122.28904024745712,37.838556649190856],[-122.28742980957031,37.838029850483494],[-122.2858193716835,37.838556649190856],[-122.28515226719908,37.83982846928078]]],[[[-122.28775390392664,37.839401223187366],[-122.28842094900924,37.84067306520728],[-122.2900314331055,37.84119988584464],[-122.29164191720174,37.84067306520728],[-122.29230896228434,37.839401223187366],[-122.29164186166447,37.83812940309727],[-122.2900314331055,37.83760260438974],[-122.2884210045465,37.83812940309727],[-122.28775390392664,37.839401223187366]]],[[[-122.29555119083754,37.83792112064947],[-122.29621822253695,37.839192962668804],[-122.2978286743164,37.83971978330557],[-122.29943912609586,37.839192962668804],[-122.30010615779527,37.83792112064947],[-122.29943907056266,37.83664930055879],[-122.2978286743164,37.836122501850674],[-122.29621827807016,37.83664930055879],[-122.29555119083754,37.83792112064947]]]],"type":"MultiPolygon"};
    const output = dissolveLib.carto_dissolve(geojson);
    expect(output).toEqual({"type":"Feature","properties":{},"geometry":{"type":"MultiPolygon","coordinates":[[[[-122.30010615779527,37.83792112064947],[-122.29943907056266,37.83664930055879],[-122.2978286743164,37.836122501850674],[-122.29621827807016,37.83664930055879],[-122.29555119083754,37.83792112064947],[-122.29621822253695,37.839192962668804],[-122.2978286743164,37.83971978330557],[-122.29943912609586,37.839192962668804],[-122.30010615779527,37.83792112064947]]],[[[-122.29540646489774,37.83837888432099],[-122.2947393735248,37.83710706423049],[-122.2931289672852,37.83658026552255],[-122.29151856104559,37.83710706423049],[-122.29107891618254,37.837945254008105],[-122.2900314331055,37.83760260438974],[-122.2884210045465,37.83812940309727],[-122.28832041272621,37.83832118031071],[-122.28742980957031,37.838029850483494],[-122.2858193716835,37.838556649190856],[-122.28515226719908,37.83982846928078],[-122.28581931614504,37.84110031130087],[-122.28742980957031,37.841627131938395],[-122.28904030299559,37.84110031130087],[-122.28914086905513,37.84090856504134],[-122.2900314331055,37.84119988584464],[-122.29164191720174,37.84067306520728],[-122.29208151155797,37.83983489910944],[-122.2931289672852,37.84017754697746],[-122.29473942905928,37.8396507263405],[-122.29540646489774,37.83837888432099]]]]}});
});