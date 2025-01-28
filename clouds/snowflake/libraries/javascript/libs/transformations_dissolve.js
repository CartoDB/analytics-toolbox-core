// Copyright (c) 2017 TurfJS
// Copyright (c) 2022 CARTO

/* eslint-disable */

import dissolve from '@turf/dissolve';

// Importing the objects from 'turf-jsts' generates a bundle of 356.96 kB.
// This is too big for a Snowflake UDF: Function definition too long.
// import { GeoJSONReader, GeoJSONWriter, BufferOp } from 'turf-jsts';

// Importing the objects from the source file generates a bundle of 234.15 kB.
// This file size fits in a Snowflake UDF \o/
import GeoJSONReader from 'turf-jsts/src/org/locationtech/jts/io/GeoJSONReader';
import GeoJSONWriter from 'turf-jsts/src/org/locationtech/jts/io/GeoJSONWriter';
import BufferOp from 'turf-jsts/src/org/locationtech/jts/operation/buffer/BufferOp';

import { featureEach, geomEach } from '@turf/meta';
// import { geoAzimuthalEquidistant } from 'd3-geo';
import { featureCollection, earthRadius, radiansToLength, lengthToRadians, feature } from '@turf/helpers';


/**
 * Calculates a buffer for input features for a given radius. Units supported are miles, kilometers, and degrees.
 *
 * When using a negative radius, the resulting geometry may be invalid if
 * it's too small compared to the radius magnitude. If the input is a
 * FeatureCollection, only valid members will be returned in the output
 * FeatureCollection - i.e., the output collection may have fewer members than
 * the input, or even be empty.
 *
 * @name buffer
 * @param {FeatureCollection|Geometry|Feature<any>} geojson input to be buffered
 * @param {number} radius distance to draw the buffer (negative values are allowed)
 * @param {Object} [options={}] Optional parameters
 * @param {string} [options.units="kilometers"] any of the options supported by turf units
 * @param {number} [options.steps=8] number of steps
 * @returns {FeatureCollection|Feature<Polygon|MultiPolygon>|undefined} buffered features
 * @example
 * var point = turf.point([-90.548630, 14.616599]);
 * var buffered = turf.buffer(point, 500, {units: 'miles'});
 *
 * //addToMap
 * var addToMap = [point, buffered]
 */
function carto_dissolve(geojson) {
  // validation
  if (!geojson) throw new Error("geojson is required");

  const polygonGeoms = unspoolPolygons(geojson);

  return dissolveFeature(
    {
      "type": "FeatureCollection",
      "features": polygonGeoms.map(
        (geom) => ({"type": "Feature", "properties": geojson.properties, "geometry": geom})
      )
    }
  );
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
      geomEach(
        geojson,
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
      featureEach(
        geojson,
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

/**
 * Coordinates isNaN
 *
 * @private
 * @param {Array<any>} coords GeoJSON Coordinates
 * @returns {boolean} if NaN exists
 */
function coordsIsNaN(coords) {
  if (Array.isArray(coords[0])) return coordsIsNaN(coords[0]);
  return isNaN(coords[0]);
}

/**
 * Project coordinates to projection
 *
 * @private
 * @param {Array<any>} coords to project
 * @param {GeoProjection} proj D3 Geo Projection
 * @returns {Array<any>} projected coordinates
 */
function projectCoords(coords, proj) {
  if (typeof coords[0] !== "object") return proj(coords);
  return coords.map(function (coord) {
    return projectCoords(coord, proj);
  });
}

/**
 * Un-Project coordinates to projection
 *
 * @private
 * @param {Array<any>} coords to un-project
 * @param {GeoProjection} proj D3 Geo Projection
 * @returns {Array<any>} un-projected coordinates
 */
function unprojectCoords(coords, proj) {
  if (typeof coords[0] !== "object") return proj.invert(coords);
  return coords.map(function (coord) {
    return unprojectCoords(coord, proj);
  });
}

/**
 * Define Azimuthal Equidistant projection
 *
 * @private
 * @param {Geometry|Feature<any>} geojson Base projection on center of GeoJSON
 * @returns {GeoProjection} D3 Geo Azimuthal Equidistant Projection
 */
function defineProjection(geojson) {
  var coords = center(geojson).geometry.coordinates;
  var rotation = [-coords[0], -coords[1]];
  return geoAzimuthalEquidistant().rotate(rotation).scale(earthRadius);
}

export default {
    carto_dissolve
};