import { h3IsValid, h3ToGeoBoundary } from '../src/h3/h3_boundary/h3core_custom';

function removeDuplicates (coordinates) {
    const precision = 0.0000000000001;
    const uniqueCoordinates = new Set();

    for (const coordinate of coordinates) {
        let isUnique = true;
        for (const uniqueCoordinate of uniqueCoordinates) {
            if (Math.abs(coordinate[0] - uniqueCoordinate[0]) < precision && Math.abs(coordinate[1] - uniqueCoordinate[1]) < precision) {
                isUnique = false;
                break;
            }
        }
        if (isUnique) {
            uniqueCoordinates.add(coordinate);
        }
    }

    return [...uniqueCoordinates];
}

export default {
    h3IsValid,
    h3ToGeoBoundary,
    removeDuplicates
};