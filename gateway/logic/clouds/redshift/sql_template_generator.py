"""
SQL Template Generator for Redshift External Functions

Generates SQL CREATE EXTERNAL FUNCTION statements from function metadata,
eliminating the need for manual SQL template files for simple functions.
"""

from typing import List, Optional
from datetime import datetime
from ...common.engine.models import Function, FunctionParameter, CloudType
from ...common.engine.type_mapper import TypeMapperRegistry

# Import Redshift type mappings to register them
from . import type_mappings  # noqa: F401


class RedshiftSQLTemplateGenerator:
    """
    Generates Redshift external function SQL from function metadata

    Supports automatic type mapping from generic types to Redshift-specific types.
    """

    @classmethod
    def generate(
        cls,
        function: Function,
        parameters: List[FunctionParameter],
        return_type: str,
        max_batch_rows: Optional[int] = None,
    ) -> str:
        """
        Generate CREATE EXTERNAL FUNCTION SQL statement

        Args:
            function: Function metadata
            parameters: Function parameters (already resolved: generic or
                       cloud-specific)
            return_type: Return type (already resolved: generic or
                        cloud-specific)
            max_batch_rows: Optional max batch rows configuration

        Returns:
            Generated SQL template string with @@VARIABLE@@ placeholders
        """
        # Map types to Redshift-specific types
        mapped_params = cls._map_parameters(parameters)
        mapped_return = cls._map_type(return_type)

        # Generate parameter list SQL
        params_sql = cls._generate_parameters_sql(mapped_params)

        # Build SQL template
        sql_parts = [
            "--------------------------------",
            f"-- Copyright (C) {datetime.now().year} CARTO",
            "--------------------------------",
            "",
            f"CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.{function.name.upper()}(",
        ]

        # Add parameters (indented)
        if params_sql:
            sql_parts.append(f"    {params_sql}")

        sql_parts.extend(
            [
                ")",
                f"RETURNS {mapped_return}",
                "STABLE",
                "LAMBDA '@@LAMBDA_ARN@@'",
                "IAM_ROLE '@@IAM_ROLE_ARN@@'",
            ]
        )

        # Add MAX_BATCH_ROWS if specified
        if max_batch_rows:
            sql_parts.append(f"MAX_BATCH_ROWS {max_batch_rows}")
        else:
            # Use template variable for dynamic configuration
            sql_parts.append("MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@")

        sql_parts.append(";")
        sql_parts.append("")  # Trailing newline

        return "\n".join(sql_parts)

    @classmethod
    def _map_parameters(
        cls, parameters: List[FunctionParameter]
    ) -> List[FunctionParameter]:
        """
        Map parameter types to Redshift-specific types

        Args:
            parameters: List of function parameters

        Returns:
            Parameters with Redshift-specific types
        """
        mapped = []
        for param in parameters:
            mapped_type = cls._map_type(param.type)
            mapped.append(
                FunctionParameter(
                    name=param.name,
                    type=mapped_type,
                    description=param.description,
                )
            )
        return mapped

    @classmethod
    def _map_type(cls, type_str: str) -> str:
        """
        Map a type to Redshift-specific SQL type

        Args:
            type_str: Generic or cloud-specific type

        Returns:
            Redshift-specific SQL type
        """
        return TypeMapperRegistry.map_type(type_str, "redshift")

    @classmethod
    def _generate_parameters_sql(cls, parameters: List[FunctionParameter]) -> str:
        """
        Generate SQL parameter list

        Args:
            parameters: List of function parameters with types

        Returns:
            SQL parameter list (e.g., "token VARCHAR(MAX), resolution INT")
        """
        if not parameters:
            return ""

        param_strs = []
        for param in parameters:
            param_strs.append(f"{param.name} {param.type}")

        # Join with comma and newline for readability
        if len(param_strs) == 1:
            return param_strs[0]
        else:
            # Multi-line parameters
            return ",\n    ".join(param_strs)

    @classmethod
    def can_generate(cls, function: Function, cloud: CloudType) -> bool:
        """
        Check if SQL template can be auto-generated for this function

        Requirements:
        - Function has parameters and return type defined (generic or cloud-specific)
        - OR external_function_template exists (legacy fallback)

        Args:
            function: Function to check
            cloud: Target cloud

        Returns:
            True if can auto-generate, False otherwise
        """
        cloud_config = function.get_cloud_config(cloud)
        if not cloud_config:
            return False

        # If template exists, use it (backward compatibility)
        if cloud_config.external_function_template:
            return False

        # Check if we have enough metadata to generate
        parameters = function.get_resolved_parameters(cloud)
        return_type = function.get_resolved_return_type(cloud)

        return parameters is not None and return_type is not None
