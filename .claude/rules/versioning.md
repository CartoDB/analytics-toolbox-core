---
paths:
  - "**/version"
  - "**/CHANGELOG*"
  - "**/RELEASING*"
---

# Versioning

## Version Files

Each cloud has independent versions in plain text files: `clouds/{cloud}/version` (e.g., `1.2.7`).

## Semver Conventions

- **feat** → minor bump
- **fix** → patch bump
- **chore/docs** → no bump
- **Breaking change** → major bump

## Version Bumping

Manual process — edit the version file directly. No automated tooling.

## How Versions Are Consumed

- `make create-package` reads `clouds/{cloud}/version` to name packages (`carto-at-{cloud}-VERSION.zip`)
- `.github/workflows/publish-release.yml` detects which version files changed to determine which clouds to publish
- Installer scripts display version at runtime

## Changelog entries are linted markdown

`make lint-common` runs `markdownlint` over each cloud's `*.md`, including `CHANGELOG.md`.
It disables MD013, MD024, MD033, MD036, MD040, MD041, MD051 and MD045 — but **not MD052**
(reference links must resolve).

So never copy a commit subject carrying two ticket ids as `[sc-1][sc-2]` straight into a
changelog: markdown reads that as a full reference link `[text][label]` whose label is
undefined, and the lint job fails. Write `[sc-1, sc-2]` in a single bracket instead. A
single `[sc-1]` is fine.

## Release Process

See `RELEASING.md` for the full process. Key steps:

1. Create `release/YYYY-MM-DD` branch
2. Bump version files for affected clouds
3. Update `CHANGELOG.md` (root + per-cloud)
4. PR to `stable` branch
5. Squash-merge triggers CI publish
