

    it ('TILEENVELOPE should fail if any NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_TILEENVELOPE(10,384,null);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });

}); /* MAKEENVELOPE integration tests */
