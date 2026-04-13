# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**CARTO Analytics Toolbox Core** is a multi-cloud spatial analytics platform providing UDFs and Stored Procedures for BigQuery, Snowflake, Redshift, Postgres, Databricks, and Oracle. Two parallel systems:

- **Gateway** (`gateway/`): Lambda-based Python functions for Redshift (build, deploy, test via `gateway/Makefile`)
- **Clouds** (`clouds/{cloud}/`): Native SQL UDFs per platform (6 clouds, each with `modules/sql/`, `modules/test/`, `libraries/`, `common/`, `version`)

## Key Commands

```bash
# Gateway (Redshift-only): build REQUIRED before tests
cd gateway
make build cloud=redshift && make test-unit cloud=redshift modules=X

# Cloud SQL UDFs
cd clouds/{cloud}
make test modules=X                  # Run tests
make deploy                          # Deploy SQL UDFs

# Root: combined gateway + clouds
make deploy cloud=redshift
make create-package cloud=redshift
```

Environment templates: `gateway/.env.template`, `clouds/{cloud}/.env.template`.

## Branching & Releases

- **`main`**: development, **`stable`**: production
- Release branches: `release/YYYY-MM-DD` targeting `stable`
- `git merge --strategy ours stable` before release commits
- Version bumps: feat → minor, fix → patch, chore/docs → none

## Conventions

[Conventional Commits](https://www.conventionalcommits.org/) with scope `(<cloud(s)>|<module(s)>)`.
Cloud codes: `bq`, `sf`, `rs`, `pg`, `db`, `ora`.

```
feat(rs|quadbin): add quadbin_polyfill function
fix(sf|h3): fix h3_polyfill boundary handling
```

## Important Notes

- **Build before testing gateway**: `make build` copies shared libs required by tests
- **Gateway is Redshift-only**: all other clouds use native SQL UDFs exclusively
- **Lambda names ≤18 chars**: use `lambda_name` field in `function.yaml`
- **Two independent systems**: Gateway and Clouds deploy separately but package together

## Detailed Documentation

Cloud-specific configuration, gateway architecture, testing, function development, CI/CD, versioning, and extending cloud support are in `.claude/rules/`. Loaded automatically when working on matching file paths.
