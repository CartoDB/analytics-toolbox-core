import { featureCollection, feature, clustersKmeans } from '@turf/turf';

function prioritizeDistinctSort(arr) {
    const uniqueValues = [];
    const duplicatedValues = [];

    // Split the array into unique and duplicated values
    const countMap = {};
    for (const item of arr) {
        if (countMap[item] === undefined) {
            countMap[item] = 1;
            uniqueValues.push(item);
        } else {
            countMap[item]++;
            duplicatedValues.push(item);
        }
    }

    // Concatenate unique and duplicated values
    const result = [...uniqueValues, ...duplicatedValues];
    return result;
}

export default {
    featureCollection,
    feature,
    clustersKmeans,
    prioritizeDistinctSort
};