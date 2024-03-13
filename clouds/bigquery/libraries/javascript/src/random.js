import { bbox, booleanPointInPolygon, randomPoint } from '@turf/turf';

function generateRandomPointsInPolygon (polygon, numPoints) {
    const randomPoints = [];
    while (randomPoints.length < numPoints) {
        const point = randomPoint(1, { bbox: bbox(polygon) }).features[0];
        if (booleanPointInPolygon(point, polygon)) {
            randomPoints.push(JSON.stringify(point.geometry));
        }
    }
    return randomPoints;
}

function generateRandomPointInPolygon (polygon) {
    let point
    do  {
        point = randomPoint(1, { bbox: bbox(polygon) }).features[0];
    } while (!booleanPointInPolygon(point, polygon))
    return JSON.stringify(point.geometry);
}

export default {
    generateRandomPointsInPolygon
};