# RELEASE PROCESS

As part of the release process we need to close the ongoing changes of any module that has received user oriented changes (features or bug fixes) since the previous release. For the new release, create a `release` branch and do the following changes:

For each module:

  * In `CHANGELOG.md` replace `## [Unreleased]` with the appropiate date.
  * Make sure the internal `VERSION()` or library version function has been updated too. Note that, for external modules, the first 3 digits come from the lib and the fourth one comes from our implementation (A.B.C.D).

Finally, update the root directory `CHANGELOG.md` making sure all noticeable changes have been added there too, add the date, pass all tests and merge.


