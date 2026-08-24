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

## Changelog entries reference the PR, not the ticket

Write `- fix(sf|data): native intersections in enrichment (#1182)`. Ticket ids belong in the
commit message and the PR description; the changelog carries the PR number, which is the
durable reference a reader can actually follow. Nearly every release since 2024 is PR-only —
the handful of `[sc-...]` entries in the history are strays, not the pattern. The one
reasonable exception is a change committed straight to the release branch with no PR of its
own, where the ticket is the only reference available.

Keeping ticket ids out also avoids a linter trap: `make lint-common` runs `markdownlint` over
each cloud's `*.md` including `CHANGELOG.md` and does not disable MD052, so two ids written
`[sc-1][sc-2]` parse as a reference link with an undefined label and fail the job.

## Release Process

See `RELEASING.md` for the full process. Key steps:

1. Create `release/YYYY-MM-DD` branch
2. Bump version files for affected clouds
3. Update `CHANGELOG.md` (root + per-cloud)
4. PR to `stable` branch
5. Squash-merge triggers CI publish
