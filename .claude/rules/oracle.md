---
paths:
  - "clouds/oracle/**"
---

# Oracle

## Configuration

Create a `.env` file in `clouds/oracle/` (template: `clouds/oracle/.env.template`):

```bash
ORA_PREFIX=DEV_                # Schema prefix (e.g., "DEV_" -> "DEV_CARTO", empty for production)
ORA_USER=<user>                # Database user
ORA_PASSWORD=<password>        # User password
ORA_WALLET_ZIP=<base64>        # Base64-encoded Oracle wallet ZIP
ORA_WALLET_PASSWORD=<password> # Wallet password
ORA_CONNECTION_STRING=<tns>    # Optional TNS alias override (auto-detected from wallet)
ORA_ENDPOINT=<url>             # AT Gateway Cloud Run service URL
ORA_API_BASE_URL=<url>         # CARTO API base URL
ORA_API_ACCESS_TOKEN=<token>   # CARTO API access token
```

**Note**: Oracle uses wallet-based authentication, unique among all supported clouds. Schemas use UPPERCASE naming convention (e.g., `DEV_CARTO`).

## Commands

```bash
cd clouds/oracle
make deploy                    # Deploy SQL UDFs
make test                      # Run all tests (pytest)
make test modules=map          # Run tests for specific module
make lint                      # Run linter
make lint-fix                  # Auto-fix lint issues
make remove                    # Drop deployed functions
make remove drop-schema=1      # Drop entire schema (destructive)
```

## Key Details

- New cloud (v1.0.0, March 2026), infrastructure in place
- Schema placeholder: `@@ORA_SCHEMA@@`
- `ORA_GATEWAY_SERVICE_MOCK=1` to mock gateway (no real Oracle connection)
- Deploy/test utilities in `clouds/oracle/common/`: `run_query.py`

## Oracle SQL Patterns

- Pure SQL functions: `CREATE OR REPLACE FUNCTION ... RETURN ... IS BEGIN ... END;` with `/` terminator
- PL/SQL blocks with loops for complex functions (KRING, TOCHILDREN, POLYFILL)
- No SQL BOOLEAN — use `NUMBER` (1/0) for boolean returns
- Use `CLOB` instead of `VARCHAR2(32767)` for functions producing large JSON arrays
- `AUTHID CURRENT_USER` (invoker rights) for all procedures
- Error codes in `-20100` to `-20199` range for data module errors

## Oracle Type Mapping

| Generic | Oracle | Notes |
|---------|--------|-------|
| quadbin index | `NUMBER` | 38-digit precision, safe for 64-bit |
| h3 index | `VARCHAR2(15)` | Hex string representation |
| geometry | `SDO_GEOMETRY` | Native spatial type |
| boolean | `NUMBER` | 1/0 (no SQL BOOLEAN) |
| JSON struct/array | `VARCHAR2` or `CLOB` | `CLOB` for large results |

## Oracle Native H3 Functions

Oracle AI Database (23ai+) provides `SDO_UTIL.H3_*` functions natively:
`H3_KEY`, `H3_BOUNDARY`, `H3_CENTER`, `H3_RESOLUTION`, `H3_PARENT`, `H3_IS_VALID_CELL`, `H3_IS_PENTAGON`, `H3_BASE_CELL`, `H3_NUM_CELLS`, `H3_MBR`

These return `RAW(8)` — use `RAWTOHEX`/`HEXTORAW` to bridge to `VARCHAR2` hex strings.

## Dynamic SQL in Procedures

Use Q-literal multiline strings with `REPLACE`-based named placeholders:

```sql
v_sql := q'[
    SELECT * FROM #INPUT_TABLE# WHERE #CONDITION#
]';
v_sql := REPLACE(v_sql, '#INPUT_TABLE#', p_input_table);
v_sql := REPLACE(v_sql, '#CONDITION#', v_condition);
EXECUTE IMMEDIATE v_sql;
```

Preferred over `UTL_LMS.FORMAT_MESSAGE` (limited to 5 args).
