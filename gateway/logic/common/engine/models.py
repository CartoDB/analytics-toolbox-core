"""
Data models for the Analytics Toolbox Gateway
Represents functions, deployments, and configurations
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any
from pathlib import Path
from enum import Enum


class FunctionType(Enum):
    """Type of database function"""

    SCALAR = "scalar"
    AGGREGATE = "aggregate"
    PROCEDURE = "procedure"
    TABLE = "table"


class CloudType(Enum):
    """Supported cloud platforms"""

    REDSHIFT = "redshift"
    BIGQUERY = "bigquery"
    SNOWFLAKE = "snowflake"
    DATABRICKS = "databricks"


class PlatformType(Enum):
    """Deployment platform for function runtime"""

    LAMBDA = "lambda"
    CLOUD_RUN = "cloud_run"
    SNOWPARK = "snowpark"
    UDF = "udf"


@dataclass
class FunctionArgument:
    """Function argument definition"""

    name: str
    type: str
    description: str = ""


@dataclass
class FunctionOutput:
    """Function output definition"""

    name: str
    type: str
    description: str = ""


@dataclass
class FunctionExample:
    """Example usage of a function"""

    description: str
    arguments: List[str]
    output: Any


@dataclass
class CloudConfig:
    """Cloud-specific configuration for a function"""

    type: PlatformType
    code_file: Path
    requirements_file: Optional[Path] = None
    external_function_template: Optional[Path] = None
    config: Dict[str, Any] = field(default_factory=dict)


@dataclass
class TestConfig:
    """Testing configuration"""

    dataset: Optional[str] = None
    timeout: int = 30
    unit_test_cases: Optional[Path] = None
    unit_test_file: Optional[Path] = None
    integration_test_file: Optional[Path] = None


@dataclass
class Function:
    """
    Represents a function in the Analytics Toolbox Gateway
    Maps to a function.yaml file
    """

    name: str
    function_type: FunctionType
    author: str
    description: str
    arguments: List[FunctionArgument]
    output: FunctionOutput
    examples: List[FunctionExample]
    clouds: Dict[CloudType, CloudConfig]
    test: TestConfig
    module: str = "general"
    function_path: Optional[Path] = None

    @property
    def yaml_path(self) -> Optional[Path]:
        """Get the path to the function.yaml file"""
        if self.function_path:
            return self.function_path / "function.yaml"
        return None

    def supports_cloud(self, cloud: CloudType) -> bool:
        """Check if function supports a specific cloud"""
        return cloud in self.clouds

    def get_cloud_config(self, cloud: CloudType) -> Optional[CloudConfig]:
        """Get configuration for a specific cloud"""
        return self.clouds.get(cloud)


@dataclass
class LambdaDeployment:
    """AWS Lambda deployment configuration"""

    function_name: str
    handler: str
    runtime: str
    memory_size: int
    timeout: int
    code_path: Path
    requirements: Optional[Path] = None
    environment_variables: Dict[str, str] = field(default_factory=dict)
    iam_role_arn: Optional[str] = None
    layers: List[str] = field(default_factory=list)


@dataclass
class ExternalFunctionConfig:
    """Configuration for creating external functions in the database"""

    function_name: str
    schema: str
    arguments: List[FunctionArgument]
    return_type: str
    lambda_arn: str
    iam_role_arn: str
    template_path: Path


@dataclass
class DistributionPackage:
    """Configuration for a distribution package"""

    name: str
    version: str
    cloud: CloudType
    functions: List[Function]
    output_path: Path
    metadata: Dict[str, Any] = field(default_factory=dict)
