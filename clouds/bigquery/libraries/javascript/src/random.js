import { bbox, booleanPointInPolygon, randomPoint } from '@turf/turf';

export function generateRandomPointsInPolygon (polygon, numPoints) {
    const randomPoints = [];
    while (randomPoints.length < numPoints) {
        const point = randomPoint(1, { bbox: bbox(polygon) }).features[0];
        if (booleanPointInPolygon(point, polygon)) {
            randomPoints.push(JSON.stringify(point.geometry));
        }
    }
    return randomPoints;
}