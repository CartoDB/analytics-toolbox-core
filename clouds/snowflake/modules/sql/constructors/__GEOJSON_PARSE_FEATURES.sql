----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.__GEOJSON_PARSE_FEATURES
(GEOJSON VARCHAR)
RETURNS TABLE (PROPERTIES VARCHAR, GEOM VARCHAR)
LANGUAGE javascript
AS $$
{
    processRow: function (row, rowWriter, context) {
        if (!row.GEOJSON) return;
        var obj = JSON.parse(row.GEOJSON);
        var features;
        if (obj.type === 'FeatureCollection') {
            features = obj.features || [];
        } else if (obj.type === 'Feature') {
            features = [obj];
        } else {
            rowWriter.writeRow({ PROPERTIES: '{}', GEOM: row.GEOJSON });
            return;
        }
        for (var i = 0; i < features.length; i++) {
            rowWriter.writeRow({
                PROPERTIES: JSON.stringify(features[i].properties || {}),
                GEOM: JSON.stringify(features[i].geometry)
            });
        }
    }
}
$$;
