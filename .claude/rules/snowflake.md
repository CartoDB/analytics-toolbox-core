---
paths:
  - "clouds/snowflake/**"
---

# Snowflake

## Configuration

Create a `.env` file in `clouds/snowflake/` (template: `clouds/snowflake/.env.template`):

```bash
SF_ACCOUNT=<account>             # Snowflake account identifier
SF_DATABASE=<database>           # Target database
SF_USER=<user>                   # Snowflake user
SF_PASSWORD=<password>           # Password (or use key-pair auth below)
SF_RSA_KEY=<key>                 # RSA private key (key-pair auth)
SF_RSA_KEY_PASSWORD=<password>   # RSA key passphrase (key-pair auth)
SF_PREFIX=<prefix>               # Optional schema prefix
SF_API_INTEGRATION=<name>        # Optional API integration name
SF_ENDPOINT=<url>                # Optional AT Gateway Cloud Run service URL
SF_API_BASE_URL=<url>            # Optional CARTO API base URL
SF_API_ACCESS_TOKEN=<token>      # Optional CARTO API access token
```

## Commands

```bash
cd clouds/snowflake
make deploy               # deploy modules
make test                 # run tests (Jest)
make build                # build JS libraries + SQL modules
make deploy-native-app    # deploy native app
make deploy-share         # deploy data share
```

## Key Details

- Uses JavaScript libraries and Jest for testing
- Supports native apps and data shares
- JS libraries: `clouds/snowflake/libraries/javascript/`
- Build/test utilities: `clouds/snowflake/common/`
- Modules: h3, quadbin, s2, placekey, constructors, transformations, processing, clustering, random

## Placeholder conventions

In docs, benchmark `config.template.json`, and any user-facing example: use `<my-database>.<my-schema>.<my-table>` for input tables and `<my-database>.<my-schema>.<my-output-table>` for procedure-output tables. Keep the namespace depth (<my-database>.<my-schema>) consistent across files.
