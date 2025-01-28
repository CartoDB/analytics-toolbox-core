// Copyright (c) 2017 TurfJS
// Copyright (c) 2022 CARTO

/* eslint-disable */

import dissolve from '@turf/dissolve';

// Importing the objects from the source file generates a bundle of 234.15 kB.
// This file size fits in a Snowflake UDF \o/
import GeoJSONReader from 'turf-jsts/src/org/locationtech/jts/io/GeoJSONReader';
import GeoJSONWriter from 'turf-jsts/src/org/locationtech/jts/io/GeoJSONWriter';

import { featureCollection, feature } from '@turf/helpers';

/**
 * Dissolves input polygon geometries.
 *
 * @name cartoDissolve
 * @param {FeatureCollection|Geometry|Feature<any>} geojson input to be dissolved
 * @returns {FeatureCollection|Feature<Polygon|MultiPolygon>|undefined} dissolved features
 */
function cartoDissolve(geojson) {
  // validation
  if (!geojson) throw new Error("geojson is required");

  const polygons = unspoolPolygons(geojson);

  return dissolveFeature(featureCollection(polygons.map(feature)));
}

/**
 * Extract list of polygon geometries from GeoJSON input
 *
 * @private
 * @param geojson input to be searched for polygons
 * @returns list of GeoJSON polygon geometries
 */
function unspoolPolygons(geojson)
{
  var polygons = [];
  // console.log("unspoolPolygons "+JSON.stringify(geojson))

  switch (geojson.type) {
    case "Polygon":
      // Pass along simple polygons
      polygons.push(geojson);
      break;

    case "MultiPolygon":
      // Break multipolygons into individual polygons
      geojson.coordinates.map(
        function(coords) {
          polygons.push({"type": "Polygon", "coordinates": coords});
        }
      )
      break;

    case "GeometryCollection":
      // Recursively descend into geometry collections
      geojson.geometries.map(
        function(geom) {
          var subgeoms = unspoolPolygons(geom);
          // console.log("subgeoms "+JSON.stringify(subgeoms))
          for (var i in subgeoms) {
            if (subgeoms[i]) { polygons.push(subgeoms[i]) }
          }
        }
      )
      break;

    case "FeatureCollection":
      // Recursively descend into feature collections
      geojson.features.map(
        function(feat) {
          var geoms = unspoolPolygons(feat.geometry);
          // console.log("geoms "+JSON.stringify(geoms))
          for (var i in geoms) {
            if (geoms[i]) { polygons.push(geoms[i]) }
          }
        }
      )
      break;
  }

  // console.log("polygons "+JSON.stringify(polygons))
  return polygons;
}

/**
 * Dissolve single Feature/Geometry
 *
 * @private
 * @param {Feature<any>} geojson input to be dissolved
 * @returns {Feature<Polygon|MultiPolygon>} dissolved feature
 */
function dissolveFeature(geojson)
{
  if (geojson.type != "FeatureCollection") throw new Error("Not a FeatureCollection");

  // Pass off to TurfJS dissolve()
  const dissolved_fc = dissolve(geojson);

  // Build a single geometry from returned FeatureCollection
  return feature(
    {
      "type": "MultiPolygon",
      "coordinates": dissolved_fc.features.map(
        (feature) => (feature.geometry.coordinates)
      )
    },
    geojson.properties
  );
}

export default {
    cartoDissolve
};