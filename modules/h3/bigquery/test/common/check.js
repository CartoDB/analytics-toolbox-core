console.log('Check env variables')

const variables = [
    'BQ_PROJECT',
    'BQ_DATASET',
    'GOOGLE_APPLICATION_CREDENTIALS'
];

for (const v of variables) {
    if (!process.env[v]) {
        console.error(`Missing ${v}`);
        process.exit(1);
    }
}
