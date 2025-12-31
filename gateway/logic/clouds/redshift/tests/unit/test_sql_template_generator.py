"""
Unit tests for RedshiftSQLTemplateGenerator

Tests automatic SQL template generation from function metadata
"""

from pathlib import Path
from datetime import datetime
from logic.common.engine.models import (
    Function,
    CloudConfig,
    CloudType,
    PlatformType,
    FunctionParameter,
)
from logic.clouds.redshift.sql_template_generator import RedshiftSQLTemplateGenerator


class TestRedshiftSQLTemplateGenerator:
    """Test SQL template generation for Redshift external functions"""

    def test_generate_simple_function(self):
        """Test generating SQL for a simple function with generic types"""
        function = Function(
            name="test_function",
            clouds={},
            module="test",
            parameters=[
                FunctionParameter(name="token", type="string"),
                FunctionParameter(name="resolution", type="int"),
            ],
            returns="bigint",
        )

        result = RedshiftSQLTemplateGenerator.generate(
            function=function,
            parameters=function.parameters,
            return_type=function.returns,
            max_batch_rows=1000,
        )

        # Check structure
        assert "CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.TEST_FUNCTION(" in result
        assert "token VARCHAR(MAX)" in result
        assert "resolution INT" in result
        assert "RETURNS INT8" in result
        assert "LAMBDA '@@LAMBDA_ARN@@'" in result
        assert "IAM_ROLE '@@IAM_ROLE_ARN@@'" in result
        assert "MAX_BATCH_ROWS 1000" in result
        assert f"-- Copyright (C) {datetime.now().year} CARTO" in result

    def test_generate_with_cloud_specific_types(self):
        """Test generating SQL with cloud-specific types"""
        function = Function(
            name="complex_function",
            clouds={},
            module="test",
            parameters=[
                FunctionParameter(name="geometry", type="SUPER"),
                FunctionParameter(name="value", type="FLOAT8"),
            ],
            returns="SUPER",
        )

        result = RedshiftSQLTemplateGenerator.generate(
            function=function,
            parameters=function.parameters,
            return_type=function.returns,
        )

        # Cloud-specific types should be preserved
        assert "geometry SUPER" in result
        assert "value FLOAT8" in result
        assert "RETURNS SUPER" in result

    def test_generate_with_dynamic_batch_rows(self):
        """Test generating SQL with dynamic MAX_BATCH_ROWS placeholder"""
        function = Function(
            name="test_function",
            clouds={},
            module="test",
            parameters=[FunctionParameter(name="id", type="int")],
            returns="string",
        )

        result = RedshiftSQLTemplateGenerator.generate(
            function=function,
            parameters=function.parameters,
            return_type=function.returns,
            max_batch_rows=None,  # No specific value
        )

        # Should use template variable
        assert "MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@" in result

    def test_generate_multiline_parameters(self):
        """Test generating SQL with multiple parameters formatted properly"""
        function = Function(
            name="multi_param_function",
            clouds={},
            module="test",
            parameters=[
                FunctionParameter(name="param1", type="string"),
                FunctionParameter(name="param2", type="int"),
                FunctionParameter(name="param3", type="bigint"),
            ],
            returns="boolean",
        )

        result = RedshiftSQLTemplateGenerator.generate(
            function=function,
            parameters=function.parameters,
            return_type=function.returns,
        )

        # Check multi-line parameter formatting
        assert "param1 VARCHAR(MAX)" in result
        assert "param2 INT" in result
        assert "param3 INT8" in result
        # Should have commas between parameters
        assert "," in result

    def test_generate_no_parameters(self):
        """Test generating SQL for function with no parameters"""
        function = Function(
            name="no_param_function",
            clouds={},
            module="test",
            parameters=[],
            returns="string",
        )

        result = RedshiftSQLTemplateGenerator.generate(
            function=function,
            parameters=function.parameters,
            return_type=function.returns,
        )

        # Function with no parameters should have empty parameter list
        assert (
            "@@SCHEMA@@.NO_PARAM_FUNCTION()" in result
            or "@@SCHEMA@@.NO_PARAM_FUNCTION(\n)" in result
        )
        assert "RETURNS VARCHAR(MAX)" in result

    def test_can_generate_with_metadata(self):
        """Test can_generate returns True when function has metadata"""
        function = Function(
            name="test_function",
            clouds={
                CloudType.REDSHIFT: CloudConfig(
                    type=PlatformType.LAMBDA,
                    code_file=Path("handler.py"),
                )
            },
            module="test",
            parameters=[FunctionParameter(name="x", type="int")],
            returns="int",
        )

        assert RedshiftSQLTemplateGenerator.can_generate(function, CloudType.REDSHIFT)

    def test_can_generate_with_template(self):
        """Test can_generate returns False when template exists (use template)"""
        function = Function(
            name="test_function",
            clouds={
                CloudType.REDSHIFT: CloudConfig(
                    type=PlatformType.LAMBDA,
                    code_file=Path("handler.py"),
                    external_function_template=Path("template.sql"),
                )
            },
            module="test",
            parameters=[FunctionParameter(name="x", type="int")],
            returns="int",
        )

        # Should use existing template, not generate
        assert not RedshiftSQLTemplateGenerator.can_generate(
            function, CloudType.REDSHIFT
        )

    def test_can_generate_without_metadata(self):
        """Test can_generate returns False when no metadata available"""
        function = Function(
            name="test_function",
            clouds={
                CloudType.REDSHIFT: CloudConfig(
                    type=PlatformType.LAMBDA,
                    code_file=Path("handler.py"),
                )
            },
            module="test",
            # No parameters or returns
        )

        assert not RedshiftSQLTemplateGenerator.can_generate(
            function, CloudType.REDSHIFT
        )

    def test_can_generate_with_cloud_specific_override(self):
        """Test can_generate with cloud-specific parameter overrides"""
        function = Function(
            name="test_function",
            clouds={
                CloudType.REDSHIFT: CloudConfig(
                    type=PlatformType.LAMBDA,
                    code_file=Path("handler.py"),
                    parameters=[FunctionParameter(name="x", type="SUPER")],
                    returns="SUPER",
                )
            },
            module="test",
        )

        # Cloud-specific override should enable generation
        assert RedshiftSQLTemplateGenerator.can_generate(function, CloudType.REDSHIFT)

    def test_generate_formatting(self):
        """Test generated SQL has proper formatting and structure"""
        function = Function(
            name="formatted_function",
            clouds={},
            module="test",
            parameters=[FunctionParameter(name="input", type="string")],
            returns="string",
        )

        result = RedshiftSQLTemplateGenerator.generate(
            function=function,
            parameters=function.parameters,
            return_type=function.returns,
        )

        lines = result.split("\n")

        # Check header
        assert lines[0] == "--------------------------------"
        assert "Copyright" in lines[1]
        assert lines[2] == "--------------------------------"
        assert lines[3] == ""

        # Check trailing newline
        assert result.endswith("\n")

    def test_type_mapping(self):
        """Test all generic types are properly mapped"""
        test_cases = [
            ("string", "VARCHAR(MAX)"),
            ("int", "INT"),
            ("bigint", "INT8"),
            ("float", "FLOAT4"),
            ("double", "FLOAT8"),
            ("boolean", "BOOLEAN"),
            ("object", "SUPER"),
            ("geometry", "GEOMETRY"),
        ]

        for generic_type, expected_sql_type in test_cases:
            function = Function(
                name="test",
                clouds={},
                module="test",
                parameters=[FunctionParameter(name="param", type=generic_type)],
                returns="int",
            )

            result = RedshiftSQLTemplateGenerator.generate(
                function=function,
                parameters=function.parameters,
                return_type=function.returns,
            )

            assert f"param {expected_sql_type}" in result
