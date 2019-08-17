# BigQuery JS Libs: A repository of pre-packaged libraries to be used as functions inside BigQuery

BigQuery allows you to create UDF functions using JS. In order to do so you have to upload the JS library into a Google Cloud Storage bucket and then create wrapper UDF functions to call them. We find the need of using external libraries very often so we have created this repo of prepared libraries to be used within BigQuery.

Because the way BigQuery works it is possible to use UDFs that are stored on a different project/dataset than the account you are calling from. So instead of asking you to push these functions to your own BigQuery project we have made them already available inside a project called `jslibs` in the us-region.

That way using a library like Uber H3, it is as simple as:

`SELECT jslibs.h3.h3Index(latitude,longitude,7) FROM myproject.mydataset.mytable`

No need to install anything, just start using them, and if you want to see what functions are available you can always pin the project and you will see all libraries that had been **bigquerified**
