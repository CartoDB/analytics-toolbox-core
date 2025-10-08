# Changelog

CARTO Analytics Toolbox Gateway for Cloud Deployments.

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.1.0] - 2025-10-08

### Added
- Initial gateway implementation for Lambda-based external functions
- Support for Redshift external functions via AWS Lambda
- Deployment CLI with commands: deploy-all, deploy-lambda, list-functions, validate, create-package
- Interactive installer for customer distribution packages
- Integration tests using same pattern as clouds (run_query, @@RS_SCHEMA@@)
- Unit and integration test separation (make test-unit, make test-integration)
- Shared .env configuration with clouds
- Lambda deployment with automatic role creation or pre-created role support
- Cross-account Lambda invocation support with role chaining
- Function versioning disabled to use $LATEST
- SQL wrapper pattern (internal VARCHAR external function + public GEOMETRY→SUPER wrapper)

### Functions
- quadbin_polyfill: Returns array of Quadbin indices covering a geometry

### Infrastructure
- Python 3.11+ support
- CDK-free deployment (direct boto3 Lambda deployment)
- Support for RS_PREFIX for development environments
- Automatic schema calculation (RS_PREFIX + 'carto')
- Lambda configuration optimization (only update if changed)
- Retry logic for Lambda update conflicts
- Progress feedback during external function creation

### Testing
- 55 unit tests passing
- Integration tests using Redshift connection
- Pytest markers for test separation
- SSL deprecation warning suppression

### Documentation
- README.md with quick start and configuration
- Function definitions in YAML format
- Inline code documentation
- Distribution package README with installation instructions
