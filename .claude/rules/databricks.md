---
paths:
  - "clouds/databricks/**"
---

# Databricks

## Configuration

Create a `.env` file in `clouds/databricks/` (template: `clouds/databricks/.env.template`):

```bash
DB_PREFIX=yourname_            # Schema prefix (e.g., "yourname_" -> "yourname_carto")
DB_CATALOG=<catalog>           # Databricks catalog name
DB_HOST_NAME=<hostname>        # SQL Warehouse hostname
DB_HTTP_PATH=<path>            # SQL Warehouse HTTP path
DB_TOKEN=<token>               # Access token
DB_CONNECTION=<connection>     # Databricks connection string
DB_API_BASE_URL=<url>          # CARTO API base URL
DB_API_ACCESS_TOKEN=<token>    # CARTO API access token
```

## Commands

```bash
cd clouds/databricks
make deploy                    # Deploy SQL UDFs
make test                      # Run all tests (pytest)
make test modules=quadbin      # Run tests for specific module
make build-modules             # Build module packages
```

## Key Details

- Native SQL UDFs only (no gateway/Lambda)
- `quadbin` module migrated March 2026 (20 SQL functions)
- Deploy scripts in `clouds/databricks/common/`: `run_query.py`, `create_schema.py`
- Schema creation runs automatically during deploy

## Python UDF `$$` bodies: keep single quotes balanced

The documented customer install pastes the whole `modules.sql` into the
Databricks **SQL editor** and runs it ("Run all"). That splitter tracks `'…'`
string literals to know where statements end. An **odd number of single quotes**
inside an `AS $$ … $$` Python body opens a string that never closes, so the
splitter skips the closing `$$;` and merges the **next** `CREATE` into the
statement, producing:

```
[PARSE_SYNTAX_ERROR] Syntax error at or near 'CREATE': extra input 'CREATE'. SQLSTATE: 42601
```

The usual culprit is an **apostrophe in a Python `#` comment** (`it's`,
`variable's`, `don't`). The build strips `--` SQL comments but **not** Python
`#` comments, so they ship verbatim into `modules.sql`. This caused sc-558226
(and earlier sc-533564).

Rules when writing/editing `$$` Python UDFs for Databricks:

- Every `AS $$ … $$` body must contain an **even** number of `'`. Avoid
  apostrophes — write "it is" not "it's"; rephrase possessives.
- Prefer `"…"` double quotes for Python string literals where practical.

Verify before committing (flags any odd-parity body — must print nothing):

```bash
for f in $(grep -rl 'AS \$\$' clouds/databricks/modules/sql); do
  awk -v F="$f" '/AS \$\$/{b=1;q=0;s=NR;next}
    /^\$\$;/{if(b){if(q%2)print "ODD single-quote parity:",F":"s"-"NR; b=0}}
    b{q+=gsub(/'"'"'/,"",$0)}' "$f"
done
```

## Placeholder conventions

In docs, benchmark `config.template.json`, and any user-facing example: use `<my-catalog>.<my-schema>.<my-table>` for input tables and `<my-catalog>.<my-schema>.<my-output-table>` for procedure-output tables. Keep the namespace depth (<my-catalog>.<my-schema>) consistent across files.
