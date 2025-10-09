"""
Distribution package builder
Creates customer-installable packages
"""

import zipfile
import shutil
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
        self,
        functions: List[Function],
        output_dir: Path,
        production: bool = False,
    ) -> Path:
        """
        Create a complete distribution package

        Args:
            functions: List of functions to include
            output_dir: Output directory for package
            production: Whether installer should be for production mode

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

        # Build package structure
        self._create_logic_dir(functions, package_dir)
        self._create_scripts_dir(package_dir, production)
        self._create_documentation(package_dir, functions)

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

    def _create_scripts_dir(self, package_dir: Path, production: bool):
        """Create installation scripts

        Args:
            package_dir: Package directory
            production: Whether installer is for production mode
        """
        scripts_dir = ensure_dir(package_dir / "scripts")

        # Production packages skip schema prefix prompt (hard-coded to empty)
        is_production = production

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
@click.option('--lambda-prefix', help='Lambda function name prefix (default: carto-at-)')  # noqa: E501
@click.option('--lambda-execution-role-arn', help='Pre-created Lambda execution role ARN (optional)')  # noqa: E501
@click.option('--rs-host', help='Redshift host endpoint')
@click.option('--rs-database', help='Redshift database name')
@click.option('--rs-user', help='Redshift user')
@click.option('--rs-password', help='Redshift password')
@click.option('--rs-prefix', help='Schema prefix for dev (leave empty for production)')  # noqa: E501
@click.option('--rs-roles', help='IAM role(s) for Redshift to invoke Lambda (comma-separated for role chaining)')  # noqa: E501
@click.option('--dry-run', is_flag=True, help='Show what would be deployed')
def install(aws_region, aws_profile, aws_access_key_id, aws_secret_access_key,
            aws_session_token, aws_assume_role_arn, lambda_prefix,
            lambda_execution_role_arn, rs_host, rs_database, rs_user, rs_password,
            rs_prefix, rs_roles, dry_run):
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
        "Lambda function prefix",
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

    # Schema prefix configuration
###SCHEMA_PREFIX_CODE###

    # RS_ROLES with enhanced guidance
    if not rs_roles:
        click.echo()
        click.secho("Redshift IAM Role Configuration:", fg='cyan', bold=True)
        click.echo("This role is attached to your Redshift cluster and used to invoke Lambda functions.")
        click.echo()
        click.echo("Options:")
        click.echo("  1. Auto-create role (RECOMMENDED for new setups)")
        click.echo("     - Leave empty to let the installer create and attach a role automatically")
        click.echo("     - Role name: {Lambda Prefix}RedshiftInvokeRole")
        click.echo(f"     - Example: {lambda_prefix.replace('-', '_').replace('_', ' ').title().replace(' ', '').replace('At', 'AT')}RedshiftInvokeRole")
        click.echo("     - Will be auto-attached to your Redshift cluster")
        click.echo()
        click.echo("  2. Use existing role (for production or cross-account)")
        click.echo("     - Provide the ARN of a role you've already created")
        click.echo("     - Example: arn:aws:iam::123456789:role/MyRedshiftLambdaRole")
        click.echo("     - Ensure it's attached to your Redshift cluster")
        click.echo()

        use_existing = click.confirm("Do you have an existing IAM role to use?", default=False)

        if use_existing:
            rs_roles = click.prompt("IAM Role ARN for Redshift to invoke Lambda")
        else:
            click.secho("✓ Will auto-create and attach IAM role during deployment", fg='green')
            rs_roles = ""  # Empty means auto-create

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
    if rs_roles:
        env_lines.append(f"RS_ROLES={rs_roles}")
    else:
        env_lines.append("# RS_ROLES not set (will auto-create and attach role)")

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
    if lambda_execution_role_arn:
        click.echo(f"Lambda Exec Role:    {lambda_execution_role_arn}")
    else:
        click.echo(f"Lambda Exec Role:    (will auto-create)")
    click.echo(f"Redshift Host:       {rs_host}")
    click.echo(f"Redshift Database:   {rs_database}")
    click.echo(f"Schema:              {rs_prefix + 'carto' if rs_prefix else 'carto'}")
    if rs_roles:
        click.echo(f"Redshift IAM Role:   {rs_roles}")
    else:
        click.echo(f"Redshift IAM Role:   (will auto-create and attach)")
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

###DEPLOY_PRODUCTION_CODE###
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

        # Generate code based on production vs dev configuration
        if is_production:
            # Production: always use empty prefix (no prompt)
            schema_prefix_code = """    rs_prefix = ""  # Production: schema='carto'"""
            deploy_production_code = """    deploy_cmd.append('--production')
"""
        else:
            # Development: prompt for prefix
            schema_prefix_code = """    if rs_prefix is None:
        rs_prefix = click.prompt(  # noqa: E501
            "Schema prefix for development (leave empty for none)",
            default="",
            show_default=False
        )"""
            deploy_production_code = ""

        # Apply substitutions using replace to avoid format() issues with {braces}
        installer_py = installer_py.replace(
            "###SCHEMA_PREFIX_CODE###", schema_prefix_code
        )
        installer_py = installer_py.replace(
            "###DEPLOY_PRODUCTION_CODE###", deploy_production_code
        )

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

    def _create_documentation(self, package_dir: Path, functions: List[Function]):
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

   The installer will guide you through the configuration. For most users, simply accept the defaults
   and the installer will auto-create necessary IAM roles.

   **Alternative: Command-line installation**
   ```bash
   python scripts/install.py \\
     --aws-region us-east-1 \\
     --aws-profile my-profile \\
     --lambda-prefix mycompany- \\
     --rs-host cluster.redshift.amazonaws.com \\
     --rs-database mydb \\
     --rs-user myuser \\
     --rs-password "***"
   ```

4. **IAM Roles (Automatic Setup):**

   The installer automatically creates and configures two IAM roles:

   **a) Lambda Execution Role** (for Lambda to run):
   - Role name: `<LambdaPrefix>LambdaExecutionRole` (e.g., `CartoATLambdaExecutionRole`)
   - Auto-created if not provided
   - Attached policies: `AWSLambdaBasicExecutionRole`

   **b) Redshift Invoke Role** (for Redshift to call Lambda):
   - Role name: `<LambdaPrefix>RedshiftInvokeRole` (e.g., `CartoATRedshiftInvokeRole`)
   - Auto-created if not provided
   - Auto-attached to your Redshift cluster
   - Lambda resource policies auto-configured

   **For production or existing roles**, provide ARNs when prompted:
   - `--lambda-execution-role-arn`: Existing Lambda execution role
   - `--rs-roles`: Existing Redshift invoke role

5. **Required AWS Permissions:**

   **Minimal permissions needed** (if using auto-creation):
   - `lambda:CreateFunction`, `lambda:UpdateFunctionCode`, `lambda:UpdateFunctionConfiguration`
   - `lambda:AddPermission` (for Redshift invoke permissions)
   - `iam:CreateRole`, `iam:PutRolePolicy`, `iam:AttachRolePolicy` (for role creation)
   - `iam:GetRole` (to check existing roles)
   - `redshift:ModifyClusterIamRoles` (to attach role to cluster)
   - `redshift:DescribeClusters` (to discover cluster)

   **Alternative: Pre-create roles** to avoid IAM permissions:
   ```bash
   # Pre-create Lambda execution role
   aws iam create-role \\
     --role-name CartoATLambdaExecutionRole \\
     --assume-role-policy-document '{{...}}'

   # Pre-create Redshift invoke role
   aws iam create-role \\
     --role-name CartoATRedshiftInvokeRole \\
     --assume-role-policy-document '{{...}}'

   # Attach to cluster
   aws redshift modify-cluster-iam-roles \\
     --cluster-identifier my-cluster \\
     --add-iam-roles arn:aws:iam::123:role/CartoATRedshiftInvokeRole
   ```

   Then provide the role ARNs during installation.

## Included Functions

This package includes {len(functions)} functions:

"""
        # Group by module
        by_module = {}
        for func in functions:
            if func.module not in by_module:
                by_module[func.module] = []
            by_module[func.module].append(func)

        for module in sorted(by_module.keys()):
            readme_content += f"\n### {module.title()}\n\n"
            for func in sorted(by_module[module], key=lambda f: f.name):
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
