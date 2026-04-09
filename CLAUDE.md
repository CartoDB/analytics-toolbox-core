# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**CARTO Analytics Toolbox Core** is a multi-cloud spatial analytics platform providing UDFs and Stored Procedures for BigQuery, Snowflake, Redshift, Postgres, Databricks, and Oracle. It has two main systems: a **Gateway** (Lambda-based Python functions for Redshift) and **Clouds** (native SQL UDFs for each platform).

## Repository Structure

```
core/
├── gateway/                   # Lambda deployment engine + functions
│   ├── functions/             # Function definitions by module
│   │   ├── quadbin/
│   │   ├── s2/
│   │   ├── clustering/
│   │   └── _shared/python/    # Shared libraries
│   ├── logic/                 # Deployment engine
│   │   ├── common/engine/     # Catalog, validators, packagers
│   │   ├── clouds/redshift/   # Redshift CLI and deployers
│   │   └── platforms/aws-lambda/
│   └── tools/                 # Build and dependency tools
│
└── clouds/{cloud}/            # Native SQL UDFs for each cloud (6 clouds)
    ├── modules/               # bigquery, snowflake, redshift, postgres, databricks, oracle
    │   ├── sql/               # SQL function definitions
    │   ├── doc/               # Function documentation
    │   └── test/              # Integration tests
    ├── libraries/             # Cloud-specific libraries (Python/JS)
    ├── common/                # Cloud-specific build scripts and utilities
    └── version                # Version file (defines package version)
```

### Cloud-Specific Modules (core)

| Cloud | Key Modules | Notes |
|-------|-------------|-------|
| BigQuery | h3, quadbin, s2, placekey, constructors, transformations, processing, clustering, random | Mature, JS-based libraries |
| Snowflake | h3, quadbin, s2, placekey, constructors, transformations, processing, clustering, random | Mature, JS-based libraries |
| Redshift | h3, quadbin, s2, placekey, constructors, transformations, processing, clustering, random | Mature, Python UDFs + Gateway Lambda |
| Postgres | h3, quadbin, s2, placekey, constructors, transformations, processing, clustering, random | Mature, SQL/PLpgSQL |
| Databricks | quadbin | Recently migrated (March 2026), 20 SQL functions |
| Oracle | (none yet) | New cloud (v1.0.0), infrastructure only, SQL modules coming |

## Key Commands

```bash
# Gateway: setup, build, test, deploy
cd gateway
make venv                                      # Create virtual environment
make build cloud=redshift                      # Build (REQUIRED before tests)
make test-unit cloud=redshift                  # Unit tests (modules=X, functions=Y)
make test-integration cloud=redshift           # Integration tests
make deploy cloud=redshift                     # Deploy Lambda functions
make lint                                      # Lint gateway code

# Cloud SQL: test and deploy
cd clouds/redshift
make test                                      # Run tests (modules=X, functions=Y)
make deploy                                    # Deploy SQL UDFs

# Root: combined operations
make deploy cloud=redshift                     # Deploy gateway + clouds
make create-package cloud=redshift             # Create distribution package
```

## Configuration

Environment templates exist at `gateway/.env.template` and `clouds/{cloud}/.env.template` (for Databricks, Oracle, etc.). Copy and fill in credentials before deploying or running integration tests.

## Branching Strategy

- **`main`**: Development branch. All feature PRs merge here.
- **`stable`**: Production branch. Only release PRs merge here.

Release branches follow `release/YYYY-MM-DD` naming and target `stable`. After merging, CI publishes packages and deploys to production.

**Release conventions:**
- Use `git merge --strategy ours stable` to handle divergence
- Commit: `release: YYYY-MM-DD` with changelog and bumped versions in body
- PR title: `Release YYYY-MM-DD`, base: `stable`
- Version bumps: feat -> minor, fix -> patch, chore/docs -> no bump

## Important Notes

- **Always build before testing gateway**: `make build cloud=redshift` before `make test-unit`
- **Shared libraries are copied during build**: Changes to `_shared/` require rebuilding
- **Lambda names must be short**: Use `lambda_name` field to keep under 18 chars total
- **Two parallel systems**: Gateway (Lambda) and Clouds (native SQL) are deployed independently but packaged together
- **Gateway is Redshift-only**: All other clouds use native SQL UDFs exclusively

## Pull Request Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(rs|quadbin): add quadbin_polyfill function
fix(sf|h3): fix h3_polyfill boundary handling
```

Scope format: `(<cloud(s)>|<module(s)>)`

Cloud codes: `bq` (BigQuery), `sf` (Snowflake), `rs` (Redshift), `pg` (Postgres), `db` (Databricks), `ora` (Oracle)

## Detailed Documentation

Detailed guides for gateway architecture, testing, function development, CI/CD, and extending cloud support are in `.claude/rules/`. These are loaded automatically when working on matching file paths.
