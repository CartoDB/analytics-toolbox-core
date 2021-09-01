# How to install the CARTO Spatial Extension

First, download and uncompress the package, for example:

```
gsutil cp gs://spatialextension_os/bigquery/packages/carto-os-spatial-extension-bigquery.zip .
unzip carto-os-spatial-extension-bigquery.zip 
```

Then, declare the input variables and run the installation script:

```
export TARGET_PROJECT=<target-project>
export TARGET_REGION=<target-region>
export TARGET_BUCKET=gs://<target-bucket>

bash install_spatial_extension.sh
```

The script will check the projects and datasets, and after that will request a confirmation (ENTER) to install the Spatial Extension: functions, procedures, and tables.

For more information, please visit the official documentation: https://docs.carto.com/spatial-extension-bq.
