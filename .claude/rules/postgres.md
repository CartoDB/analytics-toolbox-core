---
paths:
  - "clouds/postgres/**"
---

# PostgreSQL

## Configuration

Create a `.env` file in `clouds/postgres/` (template: `clouds/postgres/.env.template`):

```bash
PG_HOST=<host>       # Database host
PG_DATABASE=<db>     # Target database
PG_USER=<user>       # Database user
PG_PASSWORD=<pass>   # User password
PG_PREFIX=<prefix>   # Optional schema prefix
```

## Commands

```bash
cd clouds/postgres
make deploy   # deploy modules
make test     # run tests (pytest)
make build    # build JS libraries + SQL modules
```

## Key Details

- Uses JavaScript libraries and pytest for testing
- Schema creation is automatic
- JS libraries: `clouds/postgres/libraries/javascript/`
- Modules: h3, quadbin, s2, placekey, constructors, transformations, processing, clustering, random

## Placeholder conventions

In docs, benchmark `config.template.json`, and any user-facing example: use `<my-schema>.<my-table>` for input tables and `<my-schema>.<my-output-table>` for procedure-output tables. Keep the namespace depth (<my-schema>) consistent across files.
