# Gateway Architecture Guide

Comprehensive guide to the platform-agnostic architecture of the Analytics Toolbox Gateway.

## Table of Contents

- [Overview](#overview)
- [Design Principles](#design-principles)
- [Architecture Layers](#architecture-layers)
- [Platform-Agnostic Design](#platform-agnostic-design)
- [Separation of Concerns](#separation-of-concerns)
- [Expandability](#expandability)
- [Best Practices](#best-practices)
- [Migration Guide](#migration-guide)

## Overview

The gateway is designed to deploy Analytics Toolbox functions across multiple cloud platforms (AWS Lambda, GCP Cloud Run, etc.) and data warehouses (Redshift, BigQuery, Snowflake, etc.) while maintaining a **platform-agnostic core**.

### Key Architectural Goals

1. **Platform Independence**: Core logic works regardless of deployment platform
2. **Cloud Agnosticism**: Supports multiple data warehouses without core changes
3. **Maintainability**: Clear separation of concerns, easy to understand and modify
4. **Expandability**: Adding new platforms/clouds requires minimal changes
5. **Testability**: Each layer can be tested independently

## Design Principles

### 1. Platform-Agnostic Core

The **common engine** (`logic/common/`) contains no platform or cloud-specific code:

```
logic/common/
├── engine/          # Platform-agnostic models and logic
│   ├── models.py           # Function, CloudConfig (no AWS/GCP references)
│   ├── catalog_loader.py   # Function discovery (filesystem-based)
│   ├── validator.py        # YAML validation (cloud-agnostic)
│   └── packager.py         # Distribution packages (cloud-agnostic)
├── schemas/         # JSON schemas for validation
└── utils/           # Generic utilities (logging, paths)
```

✅ **Good**: Common code that works everywhere
```python
# logic/common/engine/models.py
class Function:
    """Platform-agnostic function representation"""
    def __init__(self, name, module, function_type):
        self.name = name
        self.module = module
        self.function_type = function_type
```

❌ **Bad**: Platform-specific code in common
```python
# DON'T DO THIS in logic/common/
import boto3  # AWS-specific - belongs in platforms/aws-lambda/

class Function:
    def deploy_to_aws(self):  # Platform-specific - wrong layer
        pass
```

### 2. Platform-Specific Extensions

**Platform code** (`logic/platforms/`) handles deployment platform specifics:

```
logic/platforms/
└── aws-lambda/
    ├── runtime/        # Lambda wrapper utilities
    └── deploy/         # AWS Lambda deployment
```

✅ **Good**: AWS-specific code in the right place
```python
# logic/platforms/aws-lambda/deploy/deployer.py
import boto3

class LambdaDeployer:
    """AWS Lambda-specific deployment"""
    def __init__(self):
        self.lambda_client = boto3.client('lambda')

    def deploy_function(self, function):
        # AWS Lambda deployment logic
        pass
```

### 3. Cloud-Specific Extensions

**Cloud code** (`logic/clouds/`) handles data warehouse specifics:

```
logic/clouds/
└── redshift/
    ├── cli.py                    # Redshift CLI
    ├── template_renderer.py      # SQL template rendering
    └── validation/               # Redshift validation
```

✅ **Good**: Redshift-specific code
```python
# logic/clouds/redshift/cli.py
class RedshiftCLI:
    """Redshift-specific deployment commands"""
    def create_external_function(self, function, lambda_arn):
        # Redshift external function SQL generation
        pass
```

### 4. Function Independence

**Functions** (`functions/`) contain business logic, agnostic to deployment:

```
functions/
└── <module>/
    └── <function>/
        ├── function.yaml       # Metadata (declares cloud support)
        ├── code/
        │   ├── lambda/python/  # Implementation
        │   └── redshift.sql    # Cloud-specific SQL template
        └── tests/              # Function tests
```

## Architecture Layers

### Layer 1: Functions (Business Logic)

**Location**: `functions/`

**Responsibility**: Implement business logic

**Dependencies**: None (pure business logic)

**Example**:
```python
# functions/examples/string_reverse/code/lambda/python/handler.py
def lambda_handler(event, context):
    """Reverse strings - pure business logic"""
    arguments = event.get('arguments', [])
    results = [[arg[0][::-1] if arg[0] else None] for arg in arguments]

    return {
        "success": True,
        "num_records": len(arguments),
        "results": results
    }
```

### Layer 2: Common Engine (Platform-Agnostic)

**Location**: `logic/common/`

**Responsibility**: Core models, validation, catalog management

**Dependencies**: None (platform-agnostic)

**Key Components**:

#### Models (`logic/common/engine/models.py`)
```python
@dataclass
class Function:
    """Platform-agnostic function representation"""
    name: str
    module: str
    function_type: str  # scalar, table, aggregate
    status: str         # development, production, deprecated
    clouds: Dict[str, CloudConfig]  # Cloud configurations

@dataclass
class CloudConfig:
    """Platform-agnostic cloud configuration"""
    type: str           # lambda, cloud_run, snowpark
    code_file: str
    external_function_template: str
    config: Dict[str, Any]
```

#### Catalog Loader (`logic/common/engine/catalog_loader.py`)
```python
class CatalogLoader:
    """Discover and load functions from filesystem"""

    def load_functions(self, modules=None, functions=None):
        """Load functions (platform-agnostic)"""
        # Walks filesystem, loads function.yaml files
        # Returns Function objects
        pass
```

#### Validator (`logic/common/engine/validator.py`)
```python
class Validator:
    """Validate function.yaml against JSON schema"""

    def validate(self, function_yaml):
        """Validate function definition (cloud-agnostic)"""
        # Uses jsonschema for validation
        # No platform-specific logic
        pass
```

### Layer 3: Platform Extensions (Deployment Platform)

**Location**: `logic/platforms/<platform>/`

**Responsibility**: Platform-specific deployment and runtime

**Dependencies**: Common engine + platform SDKs (boto3, google-cloud, etc.)

**Example: AWS Lambda**:

```python
# logic/platforms/aws-lambda/deploy/deployer.py
import boto3
from logic.common.engine.models import Function

class LambdaDeployer:
    """AWS Lambda-specific deployment"""

    def __init__(self, region, prefix):
        self.lambda_client = boto3.client('lambda', region_name=region)
        self.prefix = prefix

    def deploy(self, function: Function, cloud_config):
        """Deploy function to AWS Lambda"""
        function_name = f"{self.prefix}{function.name}"

        # Package code
        zip_bytes = self._package_code(function, cloud_config)

        # Create or update Lambda
        try:
            response = self.lambda_client.get_function(
                FunctionName=function_name
            )
            # Update existing
            self._update_function(function_name, zip_bytes, cloud_config)
        except self.lambda_client.exceptions.ResourceNotFoundException:
            # Create new
            self._create_function(function_name, zip_bytes, cloud_config)

        return self._get_function_arn(function_name)
```

**Example: Runtime Wrapper**:

```python
# logic/platforms/aws-lambda/runtime/lambda_wrapper.py
from functools import wraps

def redshift_handler(func):
    """
    Decorator for Redshift external function handlers

    Platform-agnostic business logic wrapped with
    platform-specific error handling
    """
    @wraps(func)
    def lambda_handler(event, context=None):
        try:
            arguments = event.get('arguments', [])
            results = [func(row) for row in arguments]

            return {
                "success": True,
                "num_records": len(arguments),
                "results": results
            }
        except Exception as e:
            return {
                "success": False,
                "error_msg": str(e),
                "num_records": 0,
                "results": []
            }

    return lambda_handler
```

### Layer 4: Cloud Extensions (Data Warehouse)

**Location**: `logic/clouds/<cloud>/`

**Responsibility**: Data warehouse-specific integration

**Dependencies**: Common engine + cloud database drivers

**Example: Redshift**:

```python
# logic/clouds/redshift/cli.py
import psycopg2
from logic.common.engine.catalog_loader import CatalogLoader
from logic.clouds.redshift.template_renderer import TemplateRenderer

class RedshiftCLI:
    """Redshift-specific deployment CLI"""

    def __init__(self, host, user, password, database):
        self.conn = psycopg2.connect(
            host=host, user=user, password=password, database=database
        )
        self.renderer = TemplateRenderer()

    def deploy_external_functions(
        self, functions, lambda_arns, schema, iam_role_arn
    ):
        """Create Redshift external functions"""
        for function, lambda_arn in zip(functions, lambda_arns):
            # Render SQL template
            sql = self.renderer.render(
                function.clouds['redshift'].external_function_template,
                {
                    'SCHEMA': schema,
                    'LAMBDA_ARN': lambda_arn,
                    'IAM_ROLE_ARN': iam_role_arn,
                    'FUNCTION_NAME': function.name.upper(),
                }
            )

            # Execute in Redshift
            with self.conn.cursor() as cur:
                cur.execute(sql)
            self.conn.commit()
```

**Example: Template Renderer**:

```python
# logic/clouds/redshift/template_renderer.py
class TemplateRenderer:
    """Simple @@VARIABLE@@ template renderer for SQL"""

    def render(self, template: str, variables: Dict[str, str]) -> str:
        """
        Render SQL template with simple variable substitution

        No external dependencies - just string replacement
        """
        result = template
        for key, value in variables.items():
            placeholder = f"@@{key}@@"
            result = result.replace(placeholder, str(value))
        return result
```

## Platform-Agnostic Design

### What Belongs Where?

#### Common (`logic/common/`) - Platform-Agnostic ✅

**Include**:
- Data models (Function, CloudConfig)
- Function discovery and loading
- YAML validation
- JSON schemas
- Generic utilities (logging, paths)
- Package generation logic

**Exclude**:
- ❌ AWS/GCP/Azure SDKs
- ❌ Platform-specific deployment code
- ❌ Cloud database drivers

#### Platforms (`logic/platforms/<platform>/`) - Platform-Specific ✅

**Include**:
- Platform SDK imports (boto3, google-cloud, etc.)
- Deployment code (create/update functions)
- IAM management
- Platform runtime wrappers

**Exclude**:
- ❌ Cloud database logic (belongs in clouds/)
- ❌ Business logic (belongs in functions/)

#### Clouds (`logic/clouds/<cloud>/`) - Cloud-Specific ✅

**Include**:
- Cloud database drivers (psycopg2, snowflake-connector, etc.)
- SQL template rendering
- External function creation
- Cloud-specific validation

**Exclude**:
- ❌ Platform deployment code (belongs in platforms/)
- ❌ Business logic (belongs in functions/)

#### Functions (`functions/`) - Business Logic ✅

**Include**:
- Pure business logic
- Data processing algorithms
- Function-specific tests

**Exclude**:
- ❌ Deployment code
- ❌ Platform-specific wrappers (use decorators from platforms/)
- ❌ Cloud-specific code (declare via function.yaml)

## Separation of Concerns

### Example: Deploying a Function

**Good Separation** (Current Architecture):

```python
# 1. Common: Load and validate function
from logic.common.engine.catalog_loader import CatalogLoader
from logic.common.engine.validator import Validator

loader = CatalogLoader()
validator = Validator()

function = loader.load_function("string_reverse")
validator.validate(function)

# 2. Platform: Deploy to AWS Lambda
from logic.platforms.aws_lambda.deploy.deployer import LambdaDeployer

deployer = LambdaDeployer(region="us-east-1", prefix="carto-at-")
lambda_arn = deployer.deploy(function, function.clouds['redshift'])

# 3. Cloud: Create Redshift external function
from logic.clouds.redshift.cli import RedshiftCLI

cli = RedshiftCLI(host, user, password, database)
cli.deploy_external_functions(
    [function], [lambda_arn], schema="carto", iam_role_arn
)
```

Each layer has a single responsibility and can be tested/replaced independently.

**Bad Mixing** (Anti-pattern):

```python
# DON'T DO THIS: Mixing all concerns in one place
class Deployer:
    def deploy_everything(self, function_name):
        # Validation + AWS + Redshift all mixed together
        function = self.load_yaml(function_name)  # Common concern
        zip_file = self.package_code(function)    # Platform concern
        lambda_arn = boto3.client('lambda').create_function(...)  # Platform
        psycopg2.connect(...).cursor().execute(...)  # Cloud concern

        # Hard to test, hard to add new platforms/clouds
```

## Expandability

### Adding a New Platform (e.g., GCP Cloud Run)

The architecture makes it easy to add new platforms:

**Step 1**: Create platform directory
```bash
mkdir -p logic/platforms/gcp/{runtime,deploy}
```

**Step 2**: Implement deployer
```python
# logic/platforms/gcp/deploy/deployer.py
from google.cloud import run_v2
from logic.common.engine.models import Function

class CloudRunDeployer:
    """GCP Cloud Run-specific deployment"""

    def __init__(self, project_id, region):
        self.client = run_v2.ServicesClient()
        self.project_id = project_id
        self.region = region

    def deploy(self, function: Function, cloud_config):
        """Deploy function to Cloud Run"""
        # GCP-specific deployment logic
        pass
```

**Step 3**: Create runtime utilities (if needed)
```python
# logic/platforms/gcp/runtime/cloud_run_wrapper.py
def bigquery_handler(func):
    """Decorator for BigQuery remote functions"""
    # GCP Cloud Run specific wrapper
    pass
```

**Step 4**: Update function.yaml to support new platform
```yaml
clouds:
  bigquery:
    type: cloud_run
    code_file: code/cloud_run/python/handler.py
    config:
      memory: 512Mi
      timeout: 60s
```

**No changes required** to:
- ✅ Common engine (platform-agnostic)
- ✅ Existing platforms (AWS Lambda still works)
- ✅ Existing clouds (Redshift still works)
- ✅ Functions (business logic unchanged)

### Adding a New Cloud (e.g., BigQuery)

**Step 1**: Create cloud directory
```bash
mkdir -p logic/clouds/bigquery/validation
```

**Step 2**: Implement CLI
```python
# logic/clouds/bigquery/cli.py
from google.cloud import bigquery
from logic.common.engine.models import Function

class BigQueryCLI:
    """BigQuery-specific deployment"""

    def __init__(self, project_id, dataset_id):
        self.client = bigquery.Client(project=project_id)
        self.dataset_id = dataset_id

    def deploy_remote_functions(self, functions, cloud_run_urls):
        """Create BigQuery remote functions"""
        for function, url in zip(functions, cloud_run_urls):
            # BigQuery-specific SQL generation
            sql = f"""
            CREATE OR REPLACE FUNCTION `{self.dataset_id}.{function.name}`()
            RETURNS STRING
            REMOTE WITH CONNECTION `{url}`
            """
            self.client.query(sql).result()
```

**Step 3**: Add template renderer (if needed)
```python
# logic/clouds/bigquery/template_renderer.py
class TemplateRenderer:
    """BigQuery SQL template renderer"""
    pass
```

**No changes required** to:
- ✅ Common engine
- ✅ Platforms (reuse GCP Cloud Run deployer)
- ✅ Other clouds
- ✅ Functions

## Best Practices

### 1. Keep Common Code Platform-Agnostic

✅ **Good**:
```python
# logic/common/engine/models.py
@dataclass
class CloudConfig:
    """Works for any cloud/platform"""
    type: str  # Generic: lambda, cloud_run, snowpark
    code_file: str
    config: Dict[str, Any]
```

❌ **Bad**:
```python
# logic/common/engine/models.py
@dataclass
class CloudConfig:
    """TOO SPECIFIC - belongs in platforms/"""
    lambda_arn: str  # AWS-specific
    cloud_run_url: str  # GCP-specific
```

### 2. Use Dependency Injection

✅ **Good**:
```python
class Orchestrator:
    def __init__(self, platform_deployer, cloud_cli):
        """Inject dependencies - easy to test and swap"""
        self.deployer = platform_deployer
        self.cli = cloud_cli

    def deploy(self, function):
        arn = self.deployer.deploy(function)
        self.cli.create_external_function(function, arn)
```

❌ **Bad**:
```python
class Orchestrator:
    def deploy(self, function):
        """Hard-coded dependencies - hard to test"""
        deployer = LambdaDeployer()  # Hard to replace
        cli = RedshiftCLI()  # Hard to test
```

### 3. Use Clear Interfaces

Define clear interfaces between layers:

```python
# logic/common/engine/interfaces.py
from abc import ABC, abstractmethod

class PlatformDeployer(ABC):
    """Interface for platform deployers"""

    @abstractmethod
    def deploy(self, function: Function, cloud_config: CloudConfig) -> str:
        """
        Deploy function to platform

        Returns:
            Resource identifier (ARN, URL, etc.)
        """
        pass

class CloudCLI(ABC):
    """Interface for cloud CLIs"""

    @abstractmethod
    def deploy_functions(self, functions: List[Function], resource_ids: List[str]):
        """Create cloud-native functions"""
        pass
```

Then implement for each platform/cloud:

```python
# logic/platforms/aws-lambda/deploy/deployer.py
class LambdaDeployer(PlatformDeployer):
    def deploy(self, function, cloud_config) -> str:
        # Returns Lambda ARN
        pass

# logic/clouds/redshift/cli.py
class RedshiftCLI(CloudCLI):
    def deploy_functions(self, functions, resource_ids):
        # resource_ids are Lambda ARNs
        pass
```

### 4. Document Architectural Decisions

When making changes, document WHY:

```python
# logic/clouds/redshift/template_renderer.py
"""
Simple @@VARIABLE@@ template renderer for SQL

NOTE: We intentionally use simple string replacement instead of Jinja2
to avoid external dependencies and keep the package lightweight.
This is sufficient for our use case (simple variable substitution).
"""
```

## Migration Guide

### From Monolithic to Layered

If you have existing code that mixes concerns:

**Before** (Mixed concerns):
```python
# deploy.py - everything mixed together
def deploy_function(name):
    # Load function
    with open(f'functions/{name}/function.yaml') as f:
        config = yaml.safe_load(f)

    # Package for Lambda
    zip_data = package_lambda(config)

    # Deploy to AWS
    boto3.client('lambda').create_function(...)

    # Create Redshift function
    psycopg2.connect(...).execute(...)
```

**After** (Separated concerns):
```python
# Use layered architecture
from logic.common.engine.catalog_loader import CatalogLoader
from logic.platforms.aws_lambda.deploy.deployer import LambdaDeployer
from logic.clouds.redshift.cli import RedshiftCLI

# Common: Load function
loader = CatalogLoader()
function = loader.load_function(name)

# Platform: Deploy Lambda
deployer = LambdaDeployer(...)
arn = deployer.deploy(function, function.clouds['redshift'])

# Cloud: Create external function
cli = RedshiftCLI(...)
cli.deploy_external_functions([function], [arn], ...)
```

## Related Documentation

- [README.md](README.md) - Main gateway documentation
- [STRUCTURE.md](STRUCTURE.md) - Directory structure
- [Function Development Guide](README.md#function-development)
