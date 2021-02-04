# How to contribute

The CARTO Spatial Extension is an open-source project and we are more then happy to receive your contributions.

## Submitting a patch

If you are planning a large contribution to the project, such a new module, consider opening a ticket to let us know beforehand and ensure it aligns with our roadmap and the project philosophy.

If you are changing an external library, please contribute your changes upstream and then bring the update to the Spatil Extension. That will both benefit the original project and make it easier for us to keep things simple.

### Contributor License Agreement

At CARTO, we manage a lot of open source projects and we are required to have agreements with everyone who contributes. This is the easiest way for you to give us permission to use your contributions. When you sign a Contributor License Agreement (CLA), you're giving us a license, but you still own the copyright — so you retain the right to modify your code and use it in other projects.

When you open a new Pull Request you will be asked to sign the CLA as we won't be able to accept any contributions without it.

### New modules

To contribute a new module to the project please follow these guidelines:

  1. Follow the same structure as other existing modules. Use the same building, testing and deployment rules as the other modules and add additional ones if you need to. You can copy the `skel/` directory and use it as base.

  1. All modules MUST include unit tests and integration tests against the supported databases, as well as documentation.

  1. If you include source files from other open source projects make sure we can trace where the code was originated and how to keep it up to date:
    * Ensure their license is respected. Files or directories should include their required license or copyright notices.
    * Make it easy to keep the external code updated by providing a guideline or scripts to update the code from upstream.
    * Note any changes done to the external code that aren't found upstream.

## Reporting bugs

If you find a bug, please make sure you are using the latest version of the Spatial Extension. If the issue is present and hasn't been reported already, please open a ticket describing the issue and ideally a [minimal complete verifiable example](https://matthewrocklin.com/blog/work/2018/02/28/minimal-bug-reports) detailing the affected module, how to reproduce the issue, the current output and the expected behaviour.
