"""
Unit tests for Redshift CLI
"""

import pytest
from click.testing import CliRunner
from pathlib import Path
import sys

# Add CLI to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from cli import cli  # noqa: E402


class TestRedshiftCLI:
    """Test Redshift CLI commands"""

    @pytest.fixture
    def runner(self):
        """Create a CLI runner"""
        return CliRunner()

    def test_cli_help(self, runner):
        """Test CLI help message"""
        result = runner.invoke(cli, ["--help"])
        assert result.exit_code == 0
        assert "CARTO Analytics Toolbox" in result.output

    def test_list_functions(self, runner):
        """Test list-functions command"""
        result = runner.invoke(cli, ["list-functions"])
        # Command should run (may have no functions in test env)
        assert result.exit_code in [0, 1]  # 0 = success, 1 = no functions

    def test_validate_command_exists(self, runner):
        """Test validate command exists"""
        result = runner.invoke(cli, ["validate", "--help"])
        assert result.exit_code == 0
        assert "Validate" in result.output

    def test_deploy_lambda_help(self, runner):
        """Test deploy-lambda command help"""
        result = runner.invoke(cli, ["deploy-lambda", "--help"])
        assert result.exit_code == 0
        assert "Deploy a Lambda" in result.output

    def test_create_package_help(self, runner):
        """Test create-package command help"""
        result = runner.invoke(cli, ["create-package", "--help"])
        assert result.exit_code == 0
        assert "distribution package" in result.output
