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

  var feature_collection = geojson;

  if (geojson.type == "GeometryCollection") {
    feature_collection = {
      "type": "FeatureCollection",
      "features": geojson.geometries.map(
        (geom) => ({"type": "Feature", "properties": geojson.properties, "geometry": geom})
      )
    }
  }

  var results = [];
  /*
  switch (geojson.type) {
    case "GeometryCollection":
      geomEach(geojson, function (geometry) {
        var buffered = bufferFeature(geometry, radius, units, steps);
        if (buffered) results.push(buffered);
      });
      return featureCollection(results);
    case "FeatureCollection":
      featureEach(geojson, function (feature) {
        var multiBuffered = bufferFeature(feature, radius, units, steps);
        if (multiBuffered) {
          featureEach(multiBuffered, function (buffered) {
            if (buffered) results.push(buffered);
          });
        }
      });
      return featureCollection(results);
  }
  */
  return dissolveFeature(feature_collection);
}

/**
 * Dissolve single Feature/Geometry
 *
 * @private
 * @param {Feature<any>} geojson input to be dissolved
 * @returns {Feature<Polygon|MultiPolygon>} dissolved feature
 */
function dissolveFeature(geojson) {
  if (geojson.type == "FeatureCollection") {
    const dissolved = dissolve(geojson);
    // Build a single geometry from returned FeatureCollection
    const mp = {
      "type": "MultiPolygon",
      "coordinates": dissolved.features.map(
        (feature) => (feature.geometry.coordinates)
      )
    }
    return feature(mp, properties);
  }

  var properties = geojson.properties || {};
  var geometry = geojson.type === "Feature" ? geojson.geometry : geojson;
  
  if (geometry.type == "MultiPolygon") {
    // Build a FeatureCollection as expected by TurfJS.dissolve - https://turfjs.org/docs/api/dissolve
    const fc = {
      "type": "FeatureCollection",
      "features": geometry.coordinates.map(
        (ring) => ({"type": "Feature", "geometry": {"type": "Polygon", "coordinates": ring}, "properties": properties})
      )
    }
    const dissolved = dissolve(fc);
    // Build a single geometry from returned FeatureCollection
    const mp = {
      "type": "MultiPolygon",
      "coordinates": dissolved.features.map(
        (feature) => (feature.geometry.coordinates)
      )
    }
    return feature(mp, properties);
  }
  
  throw new Error("Unsupported type: "+geometry.type)

  /*
  // Geometry Types faster than jsts
  if (geometry.type === "GeometryCollection") {
    var results = [];
    geomEach(geojson, function (geometry) {
      var buffered = bufferFeature(geometry, radius, units, steps);
      if (buffered) results.push(buffered);
    });
    return featureCollection(results);
  }

  // Project GeoJSON to Azimuthal Equidistant projection (convert to Meters)
  var projection = defineProjection(geometry);
  var projected = {
    type: geometry.type,
    coordinates: projectCoords(geometry.coordinates, projection),
  };

  // JSTS buffer operation
  var reader = new GeoJSONReader();
  var geom = reader.read(projected);
  var distance = radiansToLength(lengthToRadians(radius, units), "meters");
  var buffered = BufferOp.bufferOp(geom, distance, steps);
  var writer = new GeoJSONWriter();
  buffered = writer.write(buffered);

  // Detect if empty geometries
  if (coordsIsNaN(buffered.coordinates)) return undefined;

  // Unproject coordinates (convert to Degrees)
  var result = {
    type: buffered.type,
    coordinates: unprojectCoords(buffered.coordinates, projection),
  };

  return feature(result, properties);
  */
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