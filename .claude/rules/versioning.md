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

## Release Process

See `RELEASING.md` for the full process. Key steps:

1. Create `release/YYYY-MM-DD` branch
2. Bump version files for affected clouds
3. Update `CHANGELOG.md` (root + per-cloud)
4. PR to `stable` branch
5. Squash-merge triggers CI publish
