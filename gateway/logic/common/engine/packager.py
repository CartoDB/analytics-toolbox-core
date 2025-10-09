"""
Distribution package builder
Creates customer-installable packages with CDK infrastructure
"""

import zipfile
import shutil
import json
from pathlib import Path
from typing import List
from datetime import datetime

from .models import Function, CloudType
from ..utils import get_gateway_root, ensure_dir, get_logger

logger = get_logger("packager")


class PackageBuilder:
    """Builds distribution packages for customer installation"""

    def __init__(self, version: str, cloud: CloudType = CloudType.REDSHIFT):
        """
        Initialize package builder

        Args:
            version: Package version string
            cloud: Target cloud platform
        """
        self.version = version
        self.cloud = cloud
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    def create_package(
        self, functions: List[Function], output_dir: Path, include_private: bool = False
    ) -> Path:
        """
        Create a complete distribution package

        Args:
            functions: List of functions to include
            output_dir: Output directory for package
            include_private: Whether to include private functions

        Returns:
            Path to created package
        """
        package_name = f"carto-at-{self.cloud.value}-{self.version}"
        package_dir = output_dir / package_name

        logger.info(f"Creating package: {package_name}")

        # Clean and create package directory
        if package_dir.exists():
            shutil.rmtree(package_dir)
        ensure_dir(package_dir)

        # Build package structure (CDK-free approach)
        self._create_logic_dir(functions, package_dir)
        self._create_scripts_dir(package_dir)
        self._create_documentation(package_dir, functions, include_private)

        # Create zip file
        zip_path = output_dir / f"{package_name}.zip"
        self._create_zip(package_dir, zip_path)

        logger.info(f"Package created: {zip_path}")
        return zip_path

    def _create_logic_dir(self, functions: List[Function], package_dir: Path):
        """Copy logic/ directory with deployment code and function definitions"""
        gateway_root = get_gateway_root()
        logic_src = gateway_root / "logic"
        logic_dst = package_dir / "logic"

        logger.info("Copying deployment logic...")

        # Copy the entire logic directory structure
        shutil.copytree(
            logic_src,
            logic_dst,
            ignore=shutil.ignore_patterns(
                "__pycache__",
                "*.pyc",
                "*.pyo",
                ".pytest_cache",
                ".mypy_cache",
                "*.egg-info",
            ),
        )

        # Copy functions directory (only selected functions)
        functions_src = gateway_root / "functions"
        functions_dst = package_dir / "functions"
        ensure_dir(functions_dst)

        # Copy only the functions we're deploying
        for func in functions:
            func_src = Path(func.function_path)
            if func_src.exists():
                func_dst = functions_dst / func_src.relative_to(functions_src)
                # Create parent directories
                func_dst.parent.mkdir(parents=True, exist_ok=True)
                # Copy entire function directory
                if func_src.is_dir():
                    shutil.copytree(
                        func_src,
                        func_dst,
                        ignore=shutil.ignore_patterns(
                            "__pycache__", "*.pyc", "*.pyo", ".pytest_cache"
                        ),
                    )

        logger.info(
            f"Copied deployment logic and {len(functions)} function definitions"
        )

    def _create_lambdas_dir(self, functions: List[Function], package_dir: Path):
        """Create lambdas/ directory with all Lambda code"""
        lambdas_dir = ensure_dir(package_dir / "lambdas")

        for func in functions:
            cloud_config = func.get_cloud_config(self.cloud)
            if not cloud_config:
                continue

            # Create function directory
            func_dir = ensure_dir(lambdas_dir / func.name)

            # Copy handler code
            if cloud_config.code_file.exists():
                shutil.copy2(cloud_config.code_file, func_dir / "handler.py")

            # Copy requirements if exists
            if (
                cloud_config.requirements_file
                and cloud_config.requirements_file.exists()
            ):
                shutil.copy2(
                    cloud_config.requirements_file, func_dir / "requirements.txt"
                )

        logger.info(f"Created {len(functions)} Lambda function directories")

    def _create_sql_dir(self, functions: List[Function], package_dir: Path):
        """Create sql/ directory with SQL templates and scripts"""
        sql_dir = ensure_dir(package_dir / "sql")

        # Copy schema creation script
        gateway_root = get_gateway_root()
        schema_sql = (
            gateway_root
            / "logic"
            / "clouds"
            / self.cloud.value
            / "sql"
            / "create_schema.sql"
        )
        if schema_sql.exists():
            shutil.copy2(schema_sql, sql_dir / "create_schema.sql")

        # Create external_functions.sql.j2 template
        self._create_external_functions_template(functions, sql_dir)

        # Create functions.sql for regular functions (if any)
        self._create_functions_sql(functions, sql_dir)

    def _create_external_functions_template(
        self, functions: List[Function], sql_dir: Path
    ):
        """Create Jinja2 template for external functions"""
        template_content = [
            "{# External functions template for Redshift #}",
            "{# Variables: schema, lambda_arns (dict), iam_role_arn #}",
            "",
        ]

        for func in functions:
            cloud_config = func.get_cloud_config(self.cloud)
            if not cloud_config or not cloud_config.external_function_template:
                continue

            # Read the function's SQL template
            if cloud_config.external_function_template.exists():
                with open(cloud_config.external_function_template, "r") as f:
                    func_sql = f.read()

                # Adjust template variables
                func_sql = func_sql.replace(
                    "{{ lambda_arn }}", "{{ lambda_arns['" + func.name + "'] }}"
                )

                template_content.append(f"-- {func.name}")
                template_content.append(func_sql)
                template_content.append("")

        template_path = sql_dir / "external_functions.sql.j2"
        with open(template_path, "w") as f:
            f.write("\n".join(template_content))

    def _create_functions_sql(self, functions: List[Function], sql_dir: Path):
        """Create SQL file for regular (non-external) functions if any"""
        # Placeholder - most functions will be external
        functions_sql = sql_dir / "functions.sql"
        with open(functions_sql, "w") as f:
            f.write("-- Regular UDFs and views (if any)\n")
            f.write("-- Currently all functions are Lambda-based external functions\n")

    def _create_cdk_dir(self, functions: List[Function], package_dir: Path):
        """Create CDK infrastructure code"""
        cdk_dir = ensure_dir(package_dir / "cdk")

        # Create CDK app structure
        self._create_cdk_config(cdk_dir)
        self._create_cdk_bin(cdk_dir)
        self._create_cdk_lib(functions, cdk_dir)
        self._create_custom_resource(cdk_dir)

    def _create_cdk_config(self, cdk_dir: Path):
        """Create CDK configuration files"""
        # package.json
        package_json = {
            "name": f"carto-at-{self.cloud.value}-cdk",
            "version": self.version,
            "description": "CDK infrastructure for CARTO Analytics Toolbox",
            "scripts": {"build": "tsc", "watch": "tsc -w", "cdk": "cdk"},
            "devDependencies": {
                "@types/node": "^20.0.0",
                "typescript": "^5.0.0",
                "aws-cdk": "^2.100.0",
            },
            "dependencies": {"aws-cdk-lib": "^2.100.0", "constructs": "^10.0.0"},
        }
        with open(cdk_dir / "package.json", "w") as f:
            json.dump(package_json, f, indent=2)

        # tsconfig.json
        tsconfig = {
            "compilerOptions": {
                "target": "ES2020",
                "module": "commonjs",
                "lib": ["ES2020"],
                "declaration": True,
                "strict": True,
                "noImplicitAny": True,
                "strictNullChecks": True,
                "noImplicitThis": True,
                "alwaysStrict": True,
                "esModuleInterop": True,
                "skipLibCheck": True,
                "forceConsistentCasingInFileNames": True,
            },
            "include": ["bin/**/*.ts", "lib/**/*.ts"],
            "exclude": ["node_modules"],
        }
        with open(cdk_dir / "tsconfig.json", "w") as f:
            json.dump(tsconfig, f, indent=2)

        # cdk.json
        cdk_json = {
            "app": "npx ts-node bin/app.ts",
            "context": {
                "@aws-cdk/core:enableStackNameDuplicates": True,
                "aws-cdk:enableDiffNoFail": True,
            },
        }
        with open(cdk_dir / "cdk.json", "w") as f:
            json.dump(cdk_json, f, indent=2)

    def _create_cdk_bin(self, cdk_dir: Path):
        """Create CDK app entry point"""
        bin_dir = ensure_dir(cdk_dir / "bin")

        app_ts = """#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { CartoATRedshiftStack } from '../lib/redshift-gateway-stack';

const app = new cdk.App();

new CartoATRedshiftStack(app, 'CartoATRedshift', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION || 'us-east-1'
  }
});

app.synth();
"""
        with open(bin_dir / "app.ts", "w") as f:
            f.write(app_ts)

    def _create_cdk_lib(self, functions: List[Function], cdk_dir: Path):
        """Create CDK stack definition"""
        lib_dir = ensure_dir(cdk_dir / "lib")

        # This would be a full CDK stack in TypeScript
        # Simplified version for now
        stack_ts = """import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';
import * as path from 'path';

export class CartoATRedshiftStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Lambda execution role
    const lambdaExecutionRole = new iam.Role(this, 'LambdaExecutionRole', {{
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com'),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaBasicExecutionRole')
      ]
    }});

    // Redshift invoke role
    const redshiftInvokeRole = new iam.Role(this, 'RedshiftInvokeRole', {{
      assumedBy: new iam.ServicePrincipal('redshift.amazonaws.com'),
      inlinePolicies: {{
        LambdaInvokePolicy: new iam.PolicyDocument({{
          statements: [
            new iam.PolicyStatement({{
              actions: ['lambda:InvokeFunction'],
              resources: ['arn:aws:lambda:*:*:function:carto-at-*']
            }})
          ]
        }})
      }}
    }});

    // Lambda functions
"""

        # Add Lambda functions
        for func in functions:
            cloud_config = func.get_cloud_config(self.cloud)
            if not cloud_config:
                continue

            memory = cloud_config.config.get("memory_size", 512)
            timeout = cloud_config.config.get("timeout", 60)

            function_id = f"{func.name.title()}Function"
            stack_ts += f"""
    const {func.name}Lambda = new lambda.Function(this, '{function_id}', {{
      runtime: lambda.Runtime.PYTHON_3_11,
      handler: 'handler.lambda_handler',
      code: lambda.Code.fromAsset(path.join(__dirname, '../../lambdas/{func.name}')),
      functionName: `carto-at-${{cdk.Aws.STACK_NAME}}-{func.name}`,
      memorySize: {memory},
      timeout: cdk.Duration.seconds({timeout}),
      role: lambdaExecutionRole
    }});
"""

        stack_ts += """
    // Custom resource Lambda for SQL execution
    const sqlExecutorRole = new iam.Role(this, 'SqlExecutorRole', {
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com'),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaBasicExecutionRole')
      ],
      inlinePolicies: {
        RedshiftDataApi: new iam.PolicyDocument({
          statements: [
            new iam.PolicyStatement({
              actions: [
                'redshift-data:ExecuteStatement',
                'redshift-data:DescribeStatement',
                'redshift-data:GetStatementResult'
              ],
              resources: ['*']
            }),
            new iam.PolicyStatement({
              actions: ['redshift:GetClusterCredentials'],
              resources: ['*']
            })
          ]
        })
      }
    });

    const sqlExecutor = new lambda.Function(this, 'RedshiftSqlExecutor', {
      runtime: lambda.Runtime.PYTHON_3_11,
      handler: 'index.lambda_handler',
      code: lambda.Code.fromAsset(path.join(__dirname, '../src/redshift-sql-executor')),
      timeout: cdk.Duration.minutes(5),
      role: sqlExecutorRole
    });

    // Provider for custom resource
    const provider = new cdk.custom_resources.Provider(this, 'SqlExecutorProvider', {
      onEventHandler: sqlExecutor
    });

    // Store provider and lambdas for external function creation
    // These will be used by deployment scripts
    new cdk.CfnOutput(this, 'SqlExecutorProviderServiceToken', {
      value: provider.serviceToken,
      description: 'Custom resource provider for SQL execution'
    });

    // Output Lambda ARNs and role ARN
    new cdk.CfnOutput(this, 'RedshiftInvokeRoleArn', {
      value: redshiftInvokeRole.roleArn,
      description: 'IAM role ARN for Redshift to invoke Lambdas'
    });
"""

        # Add Lambda ARN outputs for each function
        for func in functions:
            cloud_config = func.get_cloud_config(self.cloud)
            if not cloud_config:
                continue

            stack_ts += f"""
    new cdk.CfnOutput(this, '{func.name.title()}LambdaArn', {{
      value: {func.name}Lambda.functionArn,
      description: 'Lambda ARN for {func.name}'
    }});
"""

        stack_ts += """
  }
}
"""

        with open(lib_dir / "redshift-gateway-stack.ts", "w") as f:
            f.write(stack_ts)

    def _create_custom_resource(self, cdk_dir: Path):
        """Create custom resource for SQL execution"""
        cr_dir = ensure_dir(cdk_dir / "src" / "redshift-sql-executor")

        # Copy the custom resource handler from the platforms directory
        handler_source = (
            Path(__file__).parent.parent.parent
            / "platforms"
            / "aws-lambda"
            / "custom-resources"
            / "redshift_sql_handler.py"
        )

        if handler_source.exists():
            import shutil

            shutil.copy(handler_source, cr_dir / "index.py")
        else:
            # Fallback: inline a basic handler
            cr_handler = '''"""
Custom resource handler for creating external functions in Redshift
"""
import boto3
import json
import logging
import time

logger = logging.getLogger()
logger.setLevel(logging.INFO)

redshift_data = boto3.client("redshift-data")

def lambda_handler(event, context):
    """CloudFormation custom resource handler"""
    try:
        logger.info(f"Event: {json.dumps(event)}")
        request_type = event["RequestType"]
        props = event["ResourceProperties"]

        physical_id = event.get(
            "PhysicalResourceId", f"RedshiftSQL-{event['LogicalResourceId']}"
        )

        if request_type in ["Create", "Update"]:
            # Execute SQL
            response = redshift_data.execute_statement(
                ClusterIdentifier=props["ClusterIdentifier"],
                Database=props["Database"],
                DbUser=props.get("DbUser"),
                Sql=props["Sql"]
            )
            # Wait for completion (simplified)
            time.sleep(5)

        return {
            "Status": "SUCCESS",
            "PhysicalResourceId": physical_id,
            "Data": {"Status": request_type}
        }
    except Exception as e:
        logger.error(f"Error: {e}")
        return {
            "Status": "FAILED",
            "PhysicalResourceId": physical_id,
            "Reason": str(e)
        }
'''
            with open(cr_dir / "index.py", "w") as f:
                f.write(cr_handler)

        with open(cr_dir / "requirements.txt", "w") as f:
            f.write("boto3>=1.26.0\n")

    def _create_scripts_dir(self, package_dir: Path):
        """Create installation scripts"""
        scripts_dir = ensure_dir(package_dir / "scripts")

        # Main installer - interactive version
        installer_py = '''#!/usr/bin/env python3
"""
CARTO Analytics Toolbox Installer for Redshift
Interactive installer for deploying Analytics Toolbox functions
"""
import click
import subprocess
import sys
import os
from pathlib import Path

def prompt_if_not_provided(value, prompt_text, default=None, hide_input=False):
    """Prompt for value if not provided via CLI argument"""
    if value:
        return value
    return click.prompt(  # noqa: E501
        prompt_text, default=default, hide_input=hide_input, show_default=True
    )

@click.command()
@click.option('--aws-region', help='AWS region (e.g., us-east-1)')
@click.option('--aws-profile', help='AWS profile name from ~/.aws/credentials')
@click.option('--aws-access-key-id', help='AWS Access Key ID (alternative to profile)')
@click.option('--aws-secret-access-key', help='AWS Secret Access Key (alternative to profile)')
@click.option('--aws-session-token', help='AWS Session Token (for temporary credentials)')
@click.option('--aws-assume-role-arn', help='IAM role ARN to assume (for cross-account)')
@click.option('--lambda-prefix', help='Lambda function name prefix (e.g., carto-at-)')  # noqa: E501
@click.option('--lambda-execution-role-arn', help='Pre-created Lambda execution role ARN (optional)')  # noqa: E501
@click.option('--rs-host', help='Redshift host endpoint')
@click.option('--rs-database', help='Redshift database name')
@click.option('--rs-user', help='Redshift user')
@click.option('--rs-password', help='Redshift password')
@click.option('--rs-prefix', help='Schema prefix for dev (leave empty for production)')  # noqa: E501
@click.option('--rs-roles', help='IAM role(s) for Redshift to invoke Lambda (comma-separated for role chaining)')  # noqa: E501
@click.option('--production', is_flag=True, help='Deploy to production (schema=carto, no prefix)')  # noqa: E501
@click.option('--dry-run', is_flag=True, help='Show what would be deployed')
def install(aws_region, aws_profile, aws_access_key_id, aws_secret_access_key,
            aws_session_token, aws_assume_role_arn, lambda_prefix,
            lambda_execution_role_arn, rs_host, rs_database, rs_user, rs_password,
            rs_prefix, rs_roles, production, dry_run):
    """Install CARTO Analytics Toolbox to Redshift

    This installer will guide you through deploying Analytics Toolbox functions
    as AWS Lambda functions with Redshift external functions.

    Supports multiple AWS authentication methods:
    1. AWS Profile (recommended): --aws-profile <profile-name>
    2. Explicit Credentials: --aws-access-key-id and --aws-secret-access-key
    3. Assume Role: --aws-assume-role-arn (requires profile or credentials first)
    4. Environment Variables: AWS_PROFILE, AWS_ACCESS_KEY_ID, etc.
    5. IAM Role: Automatic if running on EC2/ECS/Lambda

    You can provide values via command-line options or interactively.
    """

    click.echo("=" * 70)
    click.echo("CARTO Analytics Toolbox Installer for Redshift")
    click.echo("=" * 70)
    click.echo()

    if dry_run:
        click.secho("[DRY RUN MODE - No changes will be made]", fg='yellow', bold=True)
        click.echo()

    # Interactive prompts for AWS credentials
    click.echo("AWS Credential Configuration")
    click.echo("-" * 70)
    click.echo("Choose your authentication method:")
    click.echo("  1. AWS Profile (recommended - uses ~/.aws/credentials)")
    click.echo("  2. Explicit Credentials (access key + secret)")
    click.echo("  3. Environment Variables (skip if already set)")
    click.echo("  4. IAM Role (automatic if running on EC2/ECS/Lambda)")
    click.echo()

    auth_method = None
    if aws_profile:
        auth_method = "profile"
    elif aws_access_key_id and aws_secret_access_key:
        auth_method = "explicit"
    elif os.getenv("AWS_PROFILE"):
        auth_method = "env_profile"
        aws_profile = os.getenv("AWS_PROFILE")
    elif os.getenv("AWS_ACCESS_KEY_ID"):
        auth_method = "env_explicit"
        aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
        aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
        aws_session_token = os.getenv("AWS_SESSION_TOKEN")
    else:
        method_choice = click.prompt(  # noqa: E501
            "Select method",
            type=click.Choice(["1", "2", "3", "4"], case_sensitive=False),
            default="1"
        )
        if method_choice == "1":
            auth_method = "profile"
        elif method_choice == "2":
            auth_method = "explicit"
        elif method_choice == "3":
            auth_method = "env"
        elif method_choice == "4":
            auth_method = "iam_role"

    aws_region = prompt_if_not_provided(aws_region, "AWS Region", default="us-east-1")

    if auth_method == "profile":
        aws_profile = prompt_if_not_provided(aws_profile, "AWS Profile", default="default")
        click.secho(f"✓ Using AWS profile: {aws_profile}", fg="green")
    elif auth_method == "explicit":
        aws_access_key_id = prompt_if_not_provided(aws_access_key_id, "AWS Access Key ID")
        aws_secret_access_key = prompt_if_not_provided(  # noqa: E501
            aws_secret_access_key, "AWS Secret Access Key", hide_input=True
        )
        if not aws_session_token:
            aws_session_token = click.prompt(  # noqa: E501
                "AWS Session Token (optional - for temporary credentials)",
                default="",
                show_default=False
            ) or None
        click.secho("✓ Using explicit AWS credentials", fg="green")
    elif auth_method == "env" or auth_method == "env_profile" or auth_method == "env_explicit":
        click.secho("✓ Using AWS credentials from environment variables", fg="green")
    elif auth_method == "iam_role":
        click.secho("✓ Using IAM role (automatic discovery)", fg="green")

    # Optional: Assume Role
    if not aws_assume_role_arn:
        click.echo()
        assume_role = click.confirm(  # noqa: E501
            "Do you need to assume an IAM role? (for cross-account deployment)",
            default=False
        )
        if assume_role:
            aws_assume_role_arn = click.prompt("IAM Role ARN to assume")

    click.echo()

    click.echo("Lambda Configuration")
    click.echo("-" * 70)
    lambda_prefix = prompt_if_not_provided(  # noqa: E501
        lambda_prefix,
        "Lambda function prefix (e.g., 'mycompany-' or 'carto-at-')",
        default="carto-at-"
    )

    if not lambda_execution_role_arn:
        click.echo()
        click.secho("Lambda Execution Role (optional but recommended):", fg='cyan')
        click.echo("Pre-creating a Lambda execution role avoids needing IAM permissions.")  # noqa: E501
        click.echo("Leave empty to auto-create (requires IAM permissions).")
        lambda_execution_role_arn = click.prompt(  # noqa: E501
            "Lambda Execution Role ARN", default="", show_default=False
        ) or None
    click.echo()

    click.echo("Redshift Configuration")
    click.echo("-" * 70)
    rs_host = prompt_if_not_provided(  # noqa: E501
        rs_host, "Redshift Host (e.g., cluster.account.region.redshift.amazonaws.com)"
    )
    rs_database = prompt_if_not_provided(rs_database, "Redshift Database")
    rs_user = prompt_if_not_provided(rs_user, "Redshift User")
    rs_password = prompt_if_not_provided(rs_password, "Redshift Password", hide_input=True)

    if not production and rs_prefix is None:
        rs_prefix = click.prompt(  # noqa: E501
            "Schema prefix for development (leave empty for none)",
            default="",
            show_default=False
        )
    elif production:
        rs_prefix = ""

    rs_roles = prompt_if_not_provided(  # noqa: E501
        rs_roles,
        "IAM Role(s) for Redshift to invoke Lambda\\n(comma-separated for role chaining, e.g., 'role1,role2')"  # noqa: E501
    )
    click.echo()

    # Create .env file
    env_lines = ["# Auto-generated by CARTO Analytics Toolbox Installer", ""]
    env_lines.append("# AWS Configuration")
    env_lines.append(f"AWS_REGION={aws_region}")

    if auth_method == "profile" or auth_method == "env_profile":
        env_lines.append(f"AWS_PROFILE={aws_profile}")
    elif auth_method == "explicit" or auth_method == "env_explicit":
        env_lines.append(f"AWS_ACCESS_KEY_ID={aws_access_key_id}")
        env_lines.append(f"AWS_SECRET_ACCESS_KEY={aws_secret_access_key}")
        if aws_session_token:
            env_lines.append(f"AWS_SESSION_TOKEN={aws_session_token}")
    elif auth_method == "iam_role":
        env_lines.append("# Using IAM role (no explicit credentials needed)")

    if aws_assume_role_arn:
        env_lines.append(f"AWS_ASSUME_ROLE_ARN={aws_assume_role_arn}")

    env_lines.append("")
    env_lines.append("# Lambda Configuration")
    env_lines.append(f"LAMBDA_PREFIX={lambda_prefix}")
    if lambda_execution_role_arn:
        env_lines.append(f"LAMBDA_EXECUTION_ROLE_ARN={lambda_execution_role_arn}")
    else:
        env_lines.append("# LAMBDA_EXECUTION_ROLE_ARN not set (will auto-create)")

    env_lines.append("")
    env_lines.append("# Redshift Configuration")
    env_lines.append(f"RS_HOST={rs_host}")
    env_lines.append(f"RS_DATABASE={rs_database}")
    env_lines.append(f"RS_USER={rs_user}")
    env_lines.append(f"RS_PASSWORD={rs_password}")
    env_lines.append(f"RS_PREFIX={rs_prefix}")
    env_lines.append(f"RS_ROLES={rs_roles}")

    env_content = "\\n".join(env_lines) + "\\n"

    click.echo("Configuration Summary")
    click.echo("=" * 70)
    click.echo(f"AWS Region:          {aws_region}")

    if auth_method == "profile" or auth_method == "env_profile":
        click.echo(f"AWS Auth:            Profile ({aws_profile})")
    elif auth_method == "explicit" or auth_method == "env_explicit":
        click.echo(f"AWS Auth:            Explicit credentials (...{aws_access_key_id[-4:]})")
    elif auth_method == "iam_role":
        click.echo(f"AWS Auth:            IAM Role (automatic)")
    elif auth_method == "env":
        click.echo(f"AWS Auth:            Environment variables")

    if aws_assume_role_arn:
        click.echo(f"Assume Role:         {aws_assume_role_arn}")

    click.echo(f"Lambda Prefix:       {lambda_prefix}")
    click.echo(f"Redshift Host:       {rs_host}")
    click.echo(f"Redshift Database:   {rs_database}")
    click.echo(f"Schema:              {rs_prefix + 'carto' if rs_prefix else 'carto'}")
    click.echo(f"Production Mode:     {production}")
    click.echo("=" * 70)
    click.echo()

    if not dry_run:
        if not click.confirm("Proceed with installation?", default=True):
            click.echo("Installation cancelled.")
            return

    # Write .env file
    env_path = Path(__file__).parent.parent / '.env'
    click.echo(f"\\nWriting configuration to {env_path}...")
    if not dry_run:
        with open(env_path, 'w') as f:
            f.write(env_content)

    # Run deployment
    click.echo("\\n" + "=" * 70)
    click.echo("Starting Deployment")
    click.echo("=" * 70)

    deploy_cmd = [
        sys.executable,
        str(  # noqa: E501
            Path(__file__).parent.parent / 'logic' / 'clouds' / 'redshift' / 'cli.py'
        ),
        'deploy-all'
    ]

    if production:
        deploy_cmd.append('--production')

    if dry_run:
        deploy_cmd.append('--dry-run')

    click.echo(f"\\nRunning: {' '.join(deploy_cmd)}")
    click.echo()

    if not dry_run:
        result = subprocess.run(  # noqa: E501
            deploy_cmd,
            env={**os.environ, 'PYTHONPATH': str(Path(__file__).parent.parent)}
        )

        if result.returncode == 0:
            click.echo()
            click.secho("✓ Installation complete!", fg='green', bold=True)
            schema = rs_prefix + 'carto' if rs_prefix else 'carto'
            click.echo(f"Functions installed in {rs_database}.{schema}")
        else:
            click.secho("✗ Installation failed!", fg='red', bold=True)
            sys.exit(1)
    else:
        click.echo()
        click.secho("[DRY RUN] Installation would proceed here", fg='yellow')

if __name__ == '__main__':
    install()
'''
        with open(scripts_dir / "install.py", "w") as f:
            f.write(installer_py)
        (scripts_dir / "install.py").chmod(0o755)

        # Requirements - add all dependencies needed for deployment
        with open(scripts_dir / "requirements.txt", "w") as f:
            f.write("click>=8.1.0\n")
            f.write("boto3>=1.26.0\n")
            f.write("Jinja2>=3.1.0\n")
            f.write("python-dotenv>=1.0.0\n")
            f.write("redshift-connector>=2.0.0\n")
            f.write("PyYAML>=6.0\n")
            f.write("jsonschema>=4.0.0\n")

    def _create_documentation(
        self, package_dir: Path, functions: List[Function], include_private: bool
    ):
        """Create README and documentation"""
        readme_content = f"""# CARTO Analytics Toolbox for Redshift

Version: {self.version}
Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}  # noqa: E501

## Installation

1. **Prerequisites:**
   - Python 3.10+ (tested with 3.10-3.13)
   - AWS credentials with Lambda permissions
   - Access to a Redshift cluster

2. **Setup:**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\\Scripts\\activate
   pip install -r scripts/requirements.txt
   ```

3. **Install (Interactive):**
   ```bash
   python scripts/install.py
   ```

   The installer will guide you through the configuration. Alternatively, provide values via command-line:

   ```bash
   python scripts/install.py \\
     --aws-region us-east-1 \\
     --lambda-prefix mycompany- \\
     --rs-host cluster.redshift.amazonaws.com \\
     --rs-database mydb \\
     --rs-user myuser \\
     --rs-roles arn:aws:iam::123456:role/RedshiftLambdaRole
   ```

4. **AWS Permissions:**

   Your AWS user needs Lambda permissions. **Recommended approach:**

   Pre-create the Lambda execution role to avoid needing IAM permissions:
   ```bash
   aws iam create-role \\
     --role-name carto-at-lambda-execution-role \\
     --assume-role-policy-document '{{
       "Version": "2012-10-17",
       "Statement": [{{
         "Effect": "Allow",
         "Principal": {{"Service": "lambda.amazonaws.com"}},
         "Action": "sts:AssumeRole"
       }}]
     }}'

   aws iam attach-role-policy \\
     --role-name carto-at-lambda-execution-role \\
     --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
   ```

   Then use `--lambda-execution-role-arn` when running the installer.

## Included Functions

This package includes {len(functions)} functions:

"""
        # Group by category
        by_category = {}
        for func in functions:
            if func.category not in by_category:
                by_category[func.category] = []
            by_category[func.category].append(func)

        for category in sorted(by_category.keys()):
            readme_content += f"\n### {category.title()}\n\n"
            for func in sorted(by_category[category], key=lambda f: f.name):
                readme_content += (
                    f"- **{func.name.upper()}**: {func.description.split('.')[0]}\n"
                )

        readme_content += """
## Support

For issues or questions:
- Documentation: https://docs.carto.com/analytics-toolbox
- Support: support@carto.com
- GitHub: https://github.com/CartoDB/analytics-toolbox

## License

See LICENSE file for details.
"""

        with open(package_dir / "README.md", "w") as f:
            f.write(readme_content)

        # Copy architecture doc if exists
        arch_doc = (
            Path(__file__).parent.parent.parent.parent.parent / "claude_instructions.md"
        )
        if arch_doc.exists():
            shutil.copy2(arch_doc, package_dir / "ARCHITECTURE.md")

    def _create_zip(self, package_dir: Path, zip_path: Path):
        """Create zip file of the package"""
        if zip_path.exists():
            zip_path.unlink()

        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for file_path in package_dir.rglob("*"):
                if file_path.is_file():
                    arcname = file_path.relative_to(package_dir.parent)
                    zf.write(file_path, arcname)

        logger.info(f"Created zip: {zip_path}")
