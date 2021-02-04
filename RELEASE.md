# RELEASE PROCESS

As part of the release process we need to close the ongoing changes of any module that has received user oriented changes (features or bug fixes) since the previous release.

For each module:

  * In `CHANGELOG.md` replace `## Trunk` with the appropiate version and date.
  * Make sure the internal `VERSION()` or library version function has been updated too.

Finally, update the root directory `CHANGELOG.md` making sure all noticeable changes have been added there too, add a new version number, pass all tests (including private modules) and tag appropriately.
