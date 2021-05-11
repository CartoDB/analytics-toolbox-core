
    it ('Issue 29: ST_S2 should not fail.', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ST_ASID(ST_GEOGPOINT(-74.006, 40.7128), 12);`;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });

    it ('LONGLAT_ASID should fail if any NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.LONGLAT_ASID(NULL, 10, 5);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.LONGLAT_ASID(13, NULL, 5);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.LONGLAT_ASID(13, 10, NULL);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
}); /* S2 integration tests */
