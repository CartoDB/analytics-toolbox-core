"""
Configuration loader for deployment settings
Loads and merges YAML configuration files
"""

import yaml
from pathlib import Path
from typing import Dict, Any, Optional
from copy import deepcopy


class ConfigLoader:
    """Load and merge configuration from YAML files"""

    def __init__(self, base_config_path: Optional[Path] = None):
        """
        Initialize config loader

        Args:
            base_config_path: Optional base configuration file
        """
        self.base_config = {}
        if base_config_path and base_config_path.exists():
            self.base_config = self.load_config(base_config_path)

    def load_config(self, config_path: Path) -> Dict[str, Any]:
        """
        Load configuration from YAML file

        Args:
            config_path: Path to YAML config file

        Returns:
            Configuration dictionary
        """
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")

        with open(config_path, "r") as f:
            config = yaml.safe_load(f)

        return config or {}

    def merge_configs(
        self, base: Dict[str, Any], override: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Deep merge two configuration dictionaries

        Override values take precedence over base values.
        Lists are replaced, not merged.

        Args:
            base: Base configuration
            override: Override configuration

        Returns:
            Merged configuration
        """
        result = deepcopy(base)

        for key, value in override.items():
            if (
                key in result
                and isinstance(result[key], dict)
                and isinstance(value, dict)
            ):
                # Recursively merge dictionaries
                result[key] = self.merge_configs(result[key], value)
            else:
                # Override value (including lists)
                result[key] = deepcopy(value)

        return result

    def load_with_overrides(
        self, config_path: Path, overrides: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Load config and apply overrides

        Args:
            config_path: Path to config file
            overrides: Optional dictionary of overrides

        Returns:
            Merged configuration
        """
        config = self.load_config(config_path)

        # Merge with base config
        if self.base_config:
            config = self.merge_configs(self.base_config, config)

        # Apply overrides
        if overrides:
            config = self.merge_configs(config, overrides)

        return config

    # Accessor methods for specific configuration sections

    def get_environment(self, config: Dict[str, Any]) -> str:
        """Get environment name"""
        return config.get("environment", "dev")

    def get_aws_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Get AWS configuration"""
        return config.get("aws", {})

    def get_lambda_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Get Lambda configuration"""
        return config.get("lambda", {})

    def get_redshift_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Get Redshift configuration"""
        return config.get("redshift", {})

    def get_cdk_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Get CDK configuration"""
        return config.get("cdk", {})

    def get_deployment_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Get deployment configuration"""
        return config.get("deployment", {})

    def get_testing_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Get testing configuration"""
        return config.get("testing", {})

    # Helper methods for common values

    def get_aws_region(self, config: Dict[str, Any]) -> str:
        """Get AWS region from config"""
        aws_config = self.get_aws_config(config)
        return aws_config.get("region", "us-east-1")

    def get_aws_profile(self, config: Dict[str, Any]) -> Optional[str]:
        """Get AWS profile from config"""
        aws_config = self.get_aws_config(config)
        return aws_config.get("profile")

    def get_aws_account_id(self, config: Dict[str, Any]) -> Optional[str]:
        """Get AWS account ID from config"""
        aws_config = self.get_aws_config(config)
        return aws_config.get("account_id")

    def get_lambda_prefix(self, config: Dict[str, Any]) -> str:
        """Get Lambda function name prefix"""
        lambda_config = self.get_lambda_config(config)
        return lambda_config.get("prefix", "carto-at")

    def get_lambda_defaults(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Get default Lambda configuration"""
        lambda_config = self.get_lambda_config(config)
        return {
            "memory": lambda_config.get("default_memory", 512),
            "timeout": lambda_config.get("default_timeout", 60),
            "runtime": lambda_config.get("default_runtime", "python3.11"),
            "execution_role_name": lambda_config.get(
                "execution_role_name", "carto-at-lambda-execution-role"
            ),
        }

    def get_redshift_cluster_id(self, config: Dict[str, Any]) -> Optional[str]:
        """Get Redshift cluster identifier"""
        redshift_config = self.get_redshift_config(config)
        return redshift_config.get("cluster_identifier")

    def get_redshift_database(self, config: Dict[str, Any]) -> str:
        """Get Redshift database name"""
        redshift_config = self.get_redshift_config(config)
        return redshift_config.get("database", "dev")

    def get_redshift_schema(self, config: Dict[str, Any]) -> str:
        """Get Redshift schema name"""
        redshift_config = self.get_redshift_config(config)
        return redshift_config.get("schema", "carto")

    def is_incremental_deployment(self, config: Dict[str, Any]) -> bool:
        """Check if incremental deployment is enabled"""
        deployment_config = self.get_deployment_config(config)
        return deployment_config.get("incremental", False)

    def should_run_tests(self, config: Dict[str, Any]) -> bool:
        """Check if tests should be run after deployment"""
        deployment_config = self.get_deployment_config(config)
        return deployment_config.get("run_tests", True)

    def validate_config(self, config: Dict[str, Any]) -> bool:
        """
        Validate configuration has required fields

        Args:
            config: Configuration to validate

        Returns:
            True if valid

        Raises:
            ValueError: If configuration is invalid
        """
        # Check required AWS fields
        aws_config = self.get_aws_config(config)
        if not aws_config.get("region"):
            raise ValueError("AWS region is required in configuration")

        # Check required Redshift fields for deployment
        redshift_config = self.get_redshift_config(config)
        if not redshift_config.get("cluster_identifier"):
            raise ValueError("Redshift cluster_identifier is required")
        if not redshift_config.get("database"):
            raise ValueError("Redshift database is required")

        return True

    def to_dict(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Convert config to dictionary (for serialization)

        Args:
            config: Configuration

        Returns:
            Configuration as dictionary
        """
        return deepcopy(config)

    def to_yaml(self, config: Dict[str, Any], output_path: Path) -> None:
        """
        Save configuration to YAML file

        Args:
            config: Configuration to save
            output_path: Path to output file
        """
        with open(output_path, "w") as f:
            yaml.dump(config, f, default_flow_style=False, sort_keys=False)

    def __repr__(self) -> str:
        return f"ConfigLoader(base_config={bool(self.base_config)})"
