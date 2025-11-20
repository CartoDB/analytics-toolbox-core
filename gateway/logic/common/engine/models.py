"""
Data models for the Analytics Toolbox Gateway
Represents functions, deployments, and configurations
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any
from pathlib import Path
from enum import Enum


@dataclass
class FunctionParameter:
    """
    Represents a function parameter with type information

    Supports both generic types (e.g., "string") and cloud-specific types
    (e.g., "VARCHAR(MAX)")
    """

    name: str
    type: str  # Generic type or cloud-specific (e.g., "VARCHAR(MAX)")
    description: Optional[str] = None


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
class CloudConfig:
    """Cloud-specific configuration for a function"""

    type: PlatformType
    code_file: Optional[Path] = None  # Optional for SQL-only functions
    requirements_file: Optional[Path] = None
    external_function_template: Optional[Path] = None
    lambda_name: Optional[str] = None  # Override Lambda function name (without prefix)
    parameters: Optional[List[FunctionParameter]] = (
        None  # Cloud-specific parameter overrides
    )
    returns: Optional[str] = None  # Cloud-specific return type override
    config: Dict[str, Any] = field(default_factory=dict)


@dataclass
class Function:
    """
    Represents a function in the Analytics Toolbox Gateway
    Maps to a function.yaml file
    """

    name: str
    clouds: Dict[CloudType, CloudConfig]
    module: str = "general"
    function_path: Optional[Path] = None
    description: str = (
        "CARTO Analytics Toolbox function"  # Used in AWS Lambda description
    )
    parameters: Optional[List[FunctionParameter]] = (
        None  # Generic parameter definitions
    )
    returns: Optional[str] = None  # Generic return type

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

    def get_resolved_parameters(self, cloud: CloudType) -> List[FunctionParameter]:
        """
        Get resolved parameters for a specific cloud

        Cloud-specific parameters override generic parameters.

        Args:
            cloud: Target cloud platform

        Returns:
            Cloud-specific parameters if defined, otherwise generic parameters,
            or empty list if no parameters defined
        """
        cloud_config = self.get_cloud_config(cloud)
        if cloud_config and cloud_config.parameters:
            return cloud_config.parameters
        return self.parameters or []

    def get_resolved_return_type(self, cloud: CloudType) -> Optional[str]:
        """
        Get resolved return type for a specific cloud

        Cloud-specific return type overrides generic return type.

        Args:
            cloud: Target cloud platform

        Returns:
            Cloud-specific return type if defined, otherwise generic return type
        """
        cloud_config = self.get_cloud_config(cloud)
        if cloud_config and cloud_config.returns:
            return cloud_config.returns
        return self.returns


@dataclass
class PlatformDeploymentConfig:
    """
    Generic platform deployment configuration

    Replaces platform-specific configs (LambdaDeployment, etc.)
    Platform-specific fields go in platform_config dict
    """

    function_name: str
    platform_type: PlatformType
    handler: str
    runtime: str
    code_path: Path
    requirements: Optional[Path] = None
    platform_config: Dict[str, Any] = field(default_factory=dict)
    environment_variables: Dict[str, str] = field(default_factory=dict)


@dataclass
class ExternalFunctionConfig:
    """
    Configuration for creating external functions in cloud databases

    Cloud-agnostic - works with any cloud (Redshift, BigQuery, Snowflake, etc.)
    """

    function_name: str
    schema: str
    platform_identifier: str  # Platform-specific ID (Lambda ARN, Cloud Run URL, etc.)
    credentials: Dict[str, str]  # Cloud-specific auth credentials
    template_path: Path
    additional_config: Dict[str, Any] = field(
        default_factory=dict
    )  # Cloud-specific extras


@dataclass
class DistributionPackage:
    """Configuration for a distribution package"""

    name: str
    version: str
    cloud: CloudType
    functions: List[Function]
    output_path: Path
    metadata: Dict[str, Any] = field(default_factory=dict)
