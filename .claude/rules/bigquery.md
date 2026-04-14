---
paths:
  - "clouds/bigquery/**"
---

# BigQuery

## Configuration

Create a `.env` file in `clouds/bigquery/` (template: `clouds/bigquery/.env.template`):

```bash
BQ_PROJECT=<project>             # GCP project ID
BQ_BUCKET=gs://<bucket>          # GCS bucket for staging
BQ_REGION=<region>               # GCP region
GOOGLE_APPLICATION_CREDENTIALS=<path> # Path to service account JSON
BQ_PREFIX=<prefix>               # Optional schema prefix
BQ_ENDPOINT=<url>                # Optional AT Gateway Cloud Run service URL
BQ_CONNECTION=<connection>       # Optional BQ connection for remote functions
BQ_API_BASE_URL=<url>            # Optional CARTO API base URL
BQ_API_ACCESS_TOKEN=<token>      # Optional CARTO API access token
BQ_PERMISSIONS=<permissions>     # Optional permissions to grant
```

## Commands

```bash
cd clouds/bigquery
make deploy   # deploy modules
make test     # run tests (Jest)
make build    # build JS libraries + SQL modules
```

## Key Details

- Uses JavaScript libraries (built with `build_modules.js`) and Jest for testing
- The tiler module requires emscripten (`emcc` 2.0.13)
- JS libraries: `clouds/bigquery/libraries/javascript/`
- Test/build utilities: `clouds/bigquery/common/`
- Schema placeholder: `@@BQ_DATASET@@`, `@@BQ_PREFIX@@`
- Modules: h3, quadbin, s2, placekey, constructors, transformations, processing, clustering, random
