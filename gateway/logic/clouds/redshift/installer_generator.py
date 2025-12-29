"""
Redshift-specific installer generation
Generates install.py script for Redshift distribution packages
"""

from pathlib import Path


class RedshiftInstallerGenerator:
    """Generates Redshift-specific installer scripts"""

    @staticmethod
    def generate_installer_py(production: bool = False) -> str:
        """
        Generate install.py content for Redshift

        Args:
            production: Deprecated - no longer used. Schema is always
                prompted interactively.

        Returns:
            Python code for install.py
        """

        # Main installer - interactive version (Redshift-specific)
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

def prompt_if_not_provided(value, prompt_text, default=None, hide_input=False, show_default=True, required=True):
    """
    Prompt for value if not provided via CLI argument.

    Args:
        value: Pre-provided value (from CLI args)
        prompt_text: Text to display in prompt
        default: Default value if user enters nothing
        hide_input: Hide input (for passwords)
        show_default: Show default value in prompt
        required: If True, re-prompt until non-empty value provided

    Returns:
        Trimmed string value (never has leading/trailing whitespace)
    """
    # If value already provided via CLI, trim and return
    if value:
        return value.strip()

    # Interactive prompt with validation
    while True:
        result = click.prompt(  # noqa: E501
            prompt_text, default=default, hide_input=hide_input, show_default=show_default
        )

        # Always trim the result
        result = result.strip() if result else ""

        # Validate non-empty if required
        if required and not result:
            click.secho("  ✗ This field is required. Please enter a value.", fg='red')
            continue

        return result

@click.command()
@click.option('--aws-region', help='AWS region (e.g., us-east-1)')
@click.option('--aws-profile', help='AWS profile name from ~/.aws/credentials')
@click.option('--aws-access-key-id', help='AWS Access Key ID (alternative to profile)')
@click.option('--aws-secret-access-key', help='AWS Secret Access Key (alternative to profile)')
@click.option('--aws-session-token', help='AWS Session Token (for temporary credentials)')
@click.option('--aws-assume-role-arn', help='IAM role ARN to assume (for cross-account)')
@click.option('--rs-lambda-prefix', help='Lambda function name prefix (default: carto-at-)')  # noqa: E501
@click.option('--rs-lambda-execution-role', help='Pre-created Lambda execution role ARN (optional)')  # noqa: E501
@click.option('--rs-host', help='Redshift host endpoint')
@click.option('--rs-database', help='Redshift database name')
@click.option('--rs-user', help='Redshift user')
@click.option('--rs-password', help='Redshift password')
@click.option('--rs-schema', help='Schema name for Analytics Toolbox functions (default: carto)')  # noqa: E501
@click.option('--rs-lambda-invoke-role', help='IAM role(s) for Redshift to invoke Lambda (comma-separated for role chaining)')  # noqa: E501
@click.option('--rs-lambda-override/--no-rs-lambda-override', default=None, help='Override existing Lambda functions (default: yes if not specified)')  # noqa: E501
@click.option('--modules', help='Comma-separated list of modules to deploy (default: all)')
@click.option('--functions', help='Comma-separated list of functions to deploy (default: all)')
@click.option('--dry-run', is_flag=True, help='Show what would be deployed')
@click.option('--setup-gateway', is_flag=True, help='Configure gateway services (LDS, IMPORT, HTTP_REQUEST)')
@click.option('--gateway-lambda', help='Gateway Lambda function name or ARN')
@click.option('--gateway-roles', help='IAM role ARN(s) for gateway (comma-separated)')
@click.option('--gateway-api-base-url', help='CARTO API base URL')
@click.option('--gateway-api-access-token', help='CARTO API access token')
@click.option('--non-interactive', '-y', is_flag=True, help='Non-interactive mode (requires all parameters)')
def install(aws_region, aws_profile, aws_access_key_id, aws_secret_access_key,
            aws_session_token, aws_assume_role_arn, rs_lambda_prefix,
            rs_lambda_execution_role, rs_host, rs_database, rs_user, rs_password,
            rs_schema, rs_lambda_invoke_role, rs_lambda_override, modules, functions,
            dry_run, setup_gateway, gateway_lambda, gateway_roles,
            gateway_api_base_url, gateway_api_access_token, non_interactive):
    """Install CARTO Analytics Toolbox to Redshift

    This installer will guide you through deploying Analytics Toolbox functions
    as AWS Lambda functions with Redshift external functions.

    Supports multiple AWS authentication methods:
    1. AWS Profile (recommended): --aws-profile <profile-name>
    2. Explicit Credentials: --aws-access-key-id and --aws-secret-access-key
    3. Environment Variables: AWS_PROFILE, AWS_ACCESS_KEY_ID, etc.
    4. IAM Role: Automatic if running on EC2/ECS/Lambda

    Advanced options:
    - Cross-account deployment: --aws-assume-role-arn (for advanced scenarios)

    You can provide values via command-line options or interactively.
    """

    click.echo("=" * 70)
    click.echo("CARTO Analytics Toolbox Installer for Redshift")
    click.echo("=" * 70)
    click.echo()

    if dry_run:
        click.secho("[DRY RUN MODE - No changes will be made]", fg='yellow', bold=True)
        click.echo()

    # Validate non-interactive mode requirements
    if non_interactive:
        click.secho("[Non-interactive mode]", fg='cyan')
        click.echo()

        # Check for required AWS authentication
        has_aws_auth = (
            aws_profile or
            (aws_access_key_id and aws_secret_access_key) or
            os.getenv("AWS_PROFILE") or
            os.getenv("AWS_ACCESS_KEY_ID")
        )

        # Check for required Redshift parameters
        missing_params = []
        if not has_aws_auth:
            missing_params.append(
                "AWS authentication (--aws-profile or "
                "--aws-access-key-id + --aws-secret-access-key)"
            )
        if not rs_host:
            missing_params.append("--rs-host")
        if not rs_database:
            missing_params.append("--rs-database")
        if not rs_user:
            missing_params.append("--rs-user")
        if not rs_password:
            missing_params.append("--rs-password")

        if missing_params:
            click.secho("ERROR: Non-interactive mode requires all parameters", fg='red', bold=True)
            click.echo()
            click.echo("Missing required parameters:")
            for param in missing_params:
                click.echo(f"  • {param}")
            click.echo()
            click.echo("Run without --non-interactive for interactive mode,")
            click.echo("or run with --help to see all available options.")
            sys.exit(1)

    # Interactive prompts for AWS credentials
    if not non_interactive:
        click.echo("AWS Credential Configuration")
        click.echo("-" * 70)
        click.echo("Choose your authentication method:")
        click.echo("  1. AWS Profile (recommended - uses ~/.aws/credentials)")
        click.echo("  2. Explicit Credentials (access key + secret)")
        click.echo("  3. Environment Variables (skip if already set)")
        click.echo("  4. IAM Role (automatic if running on EC2/ECS/Lambda)")
        click.echo()

    auth_method = None

    # Priority 1: CLI arguments (highest priority)
    if aws_profile:
        auth_method = "profile"
    elif aws_access_key_id and aws_secret_access_key:
        auth_method = "explicit"

    # Priority 2: Interactive mode - ALWAYS prompt (even if env vars exist)
    elif not non_interactive:
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
            # Read from environment variables if available
            if os.getenv("AWS_PROFILE"):
                aws_profile = os.getenv("AWS_PROFILE")
                auth_method = "env_profile"
            elif os.getenv("AWS_ACCESS_KEY_ID"):
                aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
                aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
                aws_session_token = os.getenv("AWS_SESSION_TOKEN")
                auth_method = "env_explicit"
        elif method_choice == "4":
            auth_method = "iam_role"

    # Priority 3: Non-interactive mode - check env vars, then fallback to IAM
    elif os.getenv("AWS_PROFILE"):
        auth_method = "env_profile"
        aws_profile = os.getenv("AWS_PROFILE")
    elif os.getenv("AWS_ACCESS_KEY_ID"):
        auth_method = "env_explicit"
        aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
        aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
        aws_session_token = os.getenv("AWS_SESSION_TOKEN")
    else:
        # Non-interactive with no auth - assume IAM role
        auth_method = "iam_role"

    # Set defaults in non-interactive mode
    if non_interactive:
        aws_region = aws_region or "us-east-1"
        if auth_method == "profile":
            aws_profile = aws_profile or "default"
        rs_lambda_prefix = rs_lambda_prefix or "carto-at-"
    else:
        aws_region = prompt_if_not_provided(
            aws_region, "AWS Region (leave empty for 'us-east-1')",
            default="us-east-1", show_default=False, required=False
        )

    if auth_method == "profile" and not non_interactive:
        aws_profile = prompt_if_not_provided(
            aws_profile, "AWS Profile (leave empty for 'default')",
            default="default", show_default=False, required=False
        )
    if auth_method == "profile":
        click.secho(f"✓ Using AWS profile: {aws_profile}", fg="green")
    elif auth_method == "explicit":
        if not non_interactive:
            aws_access_key_id = prompt_if_not_provided(
                aws_access_key_id, "AWS Access Key ID"
            )
            aws_secret_access_key = prompt_if_not_provided(  # noqa: E501
                aws_secret_access_key, "AWS Secret Access Key", hide_input=True
            )
            if not aws_session_token:
                aws_session_token = click.prompt(  # noqa: E501
                    "AWS Session Token (optional - for temporary credentials)",
                    default="",
                    show_default=False
                )
                aws_session_token = aws_session_token.strip() if aws_session_token else None
        click.secho("✓ Using explicit AWS credentials", fg="green")
    elif auth_method == "env" or auth_method == "env_profile" or auth_method == "env_explicit":
        click.secho("✓ Using AWS credentials from environment variables", fg="green")
    elif auth_method == "iam_role":
        click.secho("✓ Using IAM role (automatic discovery)", fg="green")

    click.echo()

    if not non_interactive:
        click.echo("Lambda Configuration")
        click.echo("-" * 70)
        rs_lambda_prefix = prompt_if_not_provided(
            rs_lambda_prefix,
            "Lambda function prefix (leave empty for 'carto-at-')",
            default="carto-at-",
            show_default=False,
            required=False
        )

    if not rs_lambda_execution_role and not non_interactive:
        click.echo()
        click.secho("Lambda Execution Role Configuration:", fg='cyan', bold=True)
        click.echo("This role is used by Lambda functions to execute and access AWS resources.")
        click.echo()
        click.echo("You can provide an existing role ARN or leave empty to auto-create:")
        click.echo("  • Auto-create (recommended): Leave empty, requires IAM permissions")
        click.echo("  • Existing role: Provide ARN like arn:aws:iam::123456789:role/MyLambdaRole")
        click.echo()

        rs_lambda_execution_role = click.prompt(
            "Lambda Execution Role ARN (leave empty to auto-create)",
            default="",
            show_default=False
        )
        rs_lambda_execution_role = rs_lambda_execution_role.strip() if rs_lambda_execution_role else None

    if rs_lambda_execution_role:
        click.secho(f"✓ Using existing role: {rs_lambda_execution_role}", fg='green')
    elif not non_interactive:
        click.secho("✓ Will auto-create Lambda execution role during deployment", fg='green')

    # Lambda override configuration
###LAMBDA_OVERRIDE_CODE###

    click.echo()

    # Validation function for SQL identifiers (prevent SQL injection)
    def validate_sql_identifier(name, identifier_type="identifier"):
        """Validate SQL identifier to prevent SQL injection"""
        import re
        pattern = r'^[a-zA-Z_][a-zA-Z0-9_]*$'
        if not name or not re.match(pattern, name) or len(name) > 127:
            return False
        return True

    # Redshift Connection
    if not non_interactive:
        click.echo("Redshift Connection")
        click.echo("-" * 70)
        rs_host = prompt_if_not_provided(rs_host, "Redshift Host")
        rs_user = prompt_if_not_provided(rs_user, "Redshift User")
        rs_password = prompt_if_not_provided(
            rs_password, "Redshift Password", hide_input=True
        )

        click.echo()

        click.echo("Redshift Deployment Configuration")
        click.echo("-" * 70)
        rs_database = prompt_if_not_provided(rs_database, "Redshift Database")

    # Validate database name (prevent SQL injection)
    if rs_database and not validate_sql_identifier(rs_database, "database name"):
        click.secho(
            f"ERROR: Invalid database name '{rs_database}'. "
            "Must start with letter/underscore, contain only alphanumeric/underscores, max 127 chars.",
            fg='red', bold=True
        )
        sys.exit(1)

    # Schema configuration
###SCHEMA_PREFIX_CODE###

    click.echo()

    # RS_LAMBDA_INVOKE_ROLE with enhanced guidance
    if not rs_lambda_invoke_role and not non_interactive:
        click.echo()
        click.secho("Redshift IAM Role Configuration:", fg='cyan', bold=True)
        click.echo("This role is attached to your Redshift cluster and used to invoke Lambda functions.")
        click.echo()
        click.echo("You can provide an existing role ARN or leave empty to auto-create:")
        click.echo("  • Auto-create (recommended): Leave empty, will create and attach automatically")
        click.echo("  • Existing role: Provide ARN like arn:aws:iam::123456789:role/MyRedshiftRole")
        click.echo()

        rs_lambda_invoke_role = click.prompt(
            "Redshift IAM Role ARN (leave empty to auto-create)",
            default="",
            show_default=False
        )
        rs_lambda_invoke_role = rs_lambda_invoke_role.strip() if rs_lambda_invoke_role else ""

    if rs_lambda_invoke_role:
        click.secho(f"✓ Using existing role: {rs_lambda_invoke_role}", fg='green')
    elif not non_interactive:
        click.secho("✓ Will auto-create and attach IAM role during deployment", fg='green')

    click.echo()

    # Create .env file
    env_lines = ["# Auto-generated by CARTO Analytics Toolbox Installer", ""]

    # 1. AWS Authentication
    env_lines.append("# AWS Authentication")
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

    # 2. Lambda Configuration
    env_lines.append("")
    env_lines.append("# Lambda Configuration")
    env_lines.append(f"RS_LAMBDA_PREFIX={rs_lambda_prefix}")
    if rs_lambda_execution_role:
        env_lines.append(f"RS_LAMBDA_EXECUTION_ROLE={rs_lambda_execution_role}")
    else:
        env_lines.append("# RS_LAMBDA_EXECUTION_ROLE not set (will auto-create)")

    # 3. Redshift Connection
    env_lines.append("")
    env_lines.append("# Redshift Connection")
    env_lines.append(f"RS_HOST={rs_host}")
    env_lines.append(f"RS_USER={rs_user}")
    env_lines.append(f"RS_PASSWORD={rs_password}")

    # 4. Redshift Deployment Configuration
    env_lines.append("")
    env_lines.append("# Redshift Deployment Configuration")
    env_lines.append(f"RS_DATABASE={rs_database}")
    env_lines.append(f"RS_SCHEMA={rs_schema}")
    # rs_lambda_override is set via CLI flag or interactive prompt
    override_value = '1' if rs_lambda_override else '0'
    env_lines.append(f"RS_LAMBDA_OVERRIDE={override_value}")
    if rs_lambda_invoke_role:
        env_lines.append(f"RS_LAMBDA_INVOKE_ROLE={rs_lambda_invoke_role}")
    else:
        env_lines.append("# RS_LAMBDA_INVOKE_ROLE not set (will auto-create and attach role)")

    env_content = "\\n".join(env_lines) + "\\n"

    # Generate role names for display (same logic as deployer and IAM manager)
    def prefix_to_pascal_case(prefix: str) -> str:
        """Convert rs_lambda_prefix to PascalCase for IAM role naming"""
        import re
        prefix = prefix.rstrip("-_")
        parts = re.split(r"[-_]", prefix)
        pascal_parts = []
        for word in parts:
            if word:
                # Special case: 'at' becomes 'AT' (acronym)
                if word.lower() == "at":
                    pascal_parts.append("AT")
                else:
                    pascal_parts.append(word.capitalize())
        return "".join(pascal_parts)

    pascal_prefix = prefix_to_pascal_case(rs_lambda_prefix)
    lambda_exec_role_name = f"{pascal_prefix}LambdaExecutionRole"
    redshift_invoke_role_name = f"{pascal_prefix}RedshiftInvokeRole"

    click.echo("Configuration Summary")
    click.echo("=" * 70)
    click.echo(f"AWS Region:          {aws_region}")

    if auth_method == "profile" or auth_method == "env_profile":
        click.echo(f"AWS Auth:            Profile ({aws_profile})")
    elif auth_method == "explicit" or auth_method == "env_explicit":
        click.echo(f"AWS Auth:            Explicit credentials")
    elif auth_method == "iam_role":
        click.echo(f"AWS Auth:            IAM Role (automatic)")
    elif auth_method == "env":
        click.echo(f"AWS Auth:            Environment variables")

    if aws_assume_role_arn:
        click.echo(f"Assume Role:         {aws_assume_role_arn}")

    click.echo(f"Lambda Prefix:       {rs_lambda_prefix}")
    if rs_lambda_execution_role:
        click.echo(f"Lambda Exec Role:    {rs_lambda_execution_role}")
    else:
        click.echo(f"Lambda Exec Role:    {lambda_exec_role_name} (will auto-create)")
    click.echo(f"Redshift Host:       {rs_host}")
    click.echo(f"Redshift Database:   {rs_database}")
    click.echo(f"Schema:              {rs_schema}")
    if rs_lambda_invoke_role:
        click.echo(f"Redshift IAM Role:   {rs_lambda_invoke_role}")
    else:
        click.echo(f"Redshift IAM Role:   {redshift_invoke_role_name} (will auto-create and attach)")
    click.echo(f"Override Lambdas:    {'yes' if rs_lambda_override else 'no'}")
    click.echo("=" * 70)
    click.echo()

    if not dry_run and not non_interactive:
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
    click.secho("\\n" + "=" * 70, fg='cyan', bold=True)
    click.secho("Starting Deployment", fg='cyan', bold=True)
    click.secho("=" * 70, fg='cyan', bold=True)
    click.echo()

    # Phase 1 & 2: Deploy gateway (Lambdas + External Functions)
    click.echo("Phase 1-2: Deploying gateway functions...")
    deploy_cmd = [
        sys.executable,
        '-m',
        'logic.clouds.redshift.cli',
        'deploy-all'
    ]

    if modules:
        deploy_cmd.extend(['--modules', modules])

    if functions:
        deploy_cmd.extend(['--functions', functions])

    if dry_run:
        deploy_cmd.append('--dry-run')

    click.echo(f"  Running: {' '.join(deploy_cmd)}")

    if not dry_run:
        # Build environment with all configuration variables
        deploy_env = {**os.environ, 'PYTHONPATH': str(Path(__file__).parent.parent)}

        # AWS Configuration
        deploy_env['AWS_REGION'] = aws_region
        if aws_profile:
            deploy_env['AWS_PROFILE'] = aws_profile
        if aws_access_key_id:
            deploy_env['AWS_ACCESS_KEY_ID'] = aws_access_key_id
        if aws_secret_access_key:
            deploy_env['AWS_SECRET_ACCESS_KEY'] = aws_secret_access_key
        if aws_session_token:
            deploy_env['AWS_SESSION_TOKEN'] = aws_session_token
        if aws_assume_role_arn:
            deploy_env['AWS_ASSUME_ROLE_ARN'] = aws_assume_role_arn

        # Lambda Configuration
        deploy_env['RS_LAMBDA_PREFIX'] = rs_lambda_prefix
        deploy_env['RS_LAMBDA_OVERRIDE'] = '1' if rs_lambda_override else '0'
        if rs_lambda_execution_role:
            deploy_env['RS_LAMBDA_EXECUTION_ROLE'] = rs_lambda_execution_role

        # Redshift Configuration
        deploy_env['RS_HOST'] = rs_host
        deploy_env['RS_DATABASE'] = rs_database
        deploy_env['RS_USER'] = rs_user
        deploy_env['RS_PASSWORD'] = rs_password
        deploy_env['RS_SCHEMA'] = rs_schema
        if rs_lambda_invoke_role:
            deploy_env['RS_LAMBDA_INVOKE_ROLE'] = rs_lambda_invoke_role

        result = subprocess.run(  # noqa: E501
            deploy_cmd,
            env=deploy_env
        )

        if result.returncode != 0:
            click.secho("\\n✗ Gateway deployment failed!", fg='red', bold=True)
            sys.exit(1)

        click.secho("  ✓ Gateway functions deployed", fg='green')
    else:
        click.secho("  [DRY RUN] Would deploy gateway", fg='yellow')

    # Phase 3: Deploy clouds SQL (if exists)
    clouds_sql_path = Path(__file__).parent.parent / 'clouds' / 'redshift' / 'modules.sql'

    if clouds_sql_path.exists():
        click.echo("\\n=== Phase 3: Deploying SQL UDFs (clouds) ===\\n")

        if not dry_run:
            try:
                import redshift_connector

                # Connect to Redshift
                conn = redshift_connector.connect(
                    host=rs_host,
                    database=rs_database,
                    user=rs_user,
                    password=rs_password
                )

                # Create cursor for all database operations
                cursor = conn.cursor()

                # Create schema if it doesn't exist (in case Phase 2 was skipped)
                create_schema_sql = f"CREATE SCHEMA IF NOT EXISTS {rs_schema};"
                try:
                    cursor.execute(create_schema_sql)
                    conn.commit()
                    click.echo(f"  ✓ Schema ready: {rs_schema}")
                except Exception as e:
                    click.secho(f"  ⚠ Schema creation warning: {e}", fg='yellow')

                # Read modules.sql
                sql_content = clouds_sql_path.read_text()

                # Determine target schema
                schema = rs_schema

                # Replace template variables with install-time schema
                sql_content = sql_content.replace('@@RS_SCHEMA@@', schema)

                # Fallback: Detect build-time schema pattern (for backward compatibility)
                # This handles packages built before preserve-templates was added
                import re
                build_schema_pattern = re.compile(r'\\b([a-z_]+_carto)\\b')
                matches = build_schema_pattern.findall(sql_content)
                if matches:
                    build_schema = max(set(matches), key=matches.count)
                    # Only replace if different from target schema (avoid double replacement)
                    if build_schema != schema:
                        sql_content = sql_content.replace(build_schema, schema)

                # Split SQL statements using sqlparse (same as run_script.py)
                from sqlparse import split as sql_split
                statements = [s.strip() for s in sql_split(sql_content) if s.strip()]

                # Execute with progress bar
                failed_count = 0
                with click.progressbar(
                    length=len(statements),
                    label=f'  Deploying {len(statements)} SQL UDFs',
                    show_percent=False,
                    show_pos=True,
                    bar_template='%(label)s [%(bar)s] %(info)s'
                ) as bar:
                    for stmt in statements:
                        try:
                            cursor.execute(stmt)
                            bar.update(1)
                        except Exception as e:
                            failed_count += 1
                            bar.update(1)
                            # Log first error for debugging
                            if failed_count == 1:
                                error_msg = str(e).split('\\n')[0][:200]
                                click.echo(f"\\n  Note: Some functions may fail (this is normal if already exist)")
                                click.echo(f"  First error: {error_msg}")

                conn.commit()
                cursor.close()
                conn.close()

                if failed_count > 0:
                    click.secho(f"\\n  ⚠️  {failed_count} statement(s) had errors (may be normal)", fg='yellow')

                click.secho("  ✓ SQL UDFs deployed", fg='green')
            except Exception as e:
                click.secho(f"\\n✗ SQL UDF deployment failed: {e}", fg='red', bold=True)
                click.echo("  Gateway functions were deployed successfully")
                click.echo("  You may need to manually deploy clouds SQL")
                sys.exit(1)
        else:
            click.secho("  [DRY RUN] Would deploy SQL UDFs", fg='yellow')
    else:
        click.echo("\\n=== Phase 3: No clouds SQL found (gateway-only package) ===\\n")

    # Success
    if not dry_run:
        click.echo()
        click.secho("✓ Installation complete!", fg='green', bold=True)
        click.echo(f"Functions installed in {rs_database}.{rs_schema}")
    else:
        click.echo()
        click.secho("[DRY RUN] Installation would complete here", fg='yellow')

if __name__ == '__main__':
    install()
'''

        # Generate schema name prompt (always prompt, no production distinction)
        schema_name_code = """    # Schema configuration and validation
    if rs_schema is None:
        while True:
            rs_schema = click.prompt(
                "Redshift Schema (leave empty for 'carto')",
                default='carto',
                show_default=False
            )
            rs_schema = rs_schema.strip() if rs_schema else 'carto'
            if validate_sql_identifier(rs_schema, "schema name"):
                break
            click.secho(
                'ERROR: Invalid schema name. Must start with letter/underscore, '
                'contain only alphanumeric/underscores, max 127 chars.',
                fg='red', err=True
            )
    else:
        # Validate schema name provided via CLI (prevent SQL injection)
        if not validate_sql_identifier(rs_schema, "schema name"):
            click.secho(
                f"ERROR: Invalid schema name '{rs_schema}'. "
                "Must start with letter/underscore, contain only "
                "alphanumeric/underscores, max 127 chars.",
                fg='red', bold=True
            )
            sys.exit(1)
        click.echo(f"Using schema: {rs_schema}")

    click.echo()
"""

        # Generate lambda override prompt
        lambda_override_code = """
    # Lambda override configuration
    if rs_lambda_override is None:
        if non_interactive:
            rs_lambda_override = True  # Default to yes in non-interactive mode
        else:
            rs_lambda_override = click.confirm(
                'Override existing Lambda functions?',
                default=True
            )

    if rs_lambda_override is not None and not non_interactive:
        override_status = 'yes' if rs_lambda_override else 'no'
        click.echo(f"Override existing Lambdas: {override_status}")

    if not non_interactive:
        click.echo()
"""

        # Apply substitutions using replace to avoid format() issues with {braces}
        installer_py = installer_py.replace(
            "###SCHEMA_PREFIX_CODE###", schema_name_code
        )
        installer_py = installer_py.replace(
            "###LAMBDA_OVERRIDE_CODE###", lambda_override_code
        )

        return installer_py

    @staticmethod
    def generate_requirements_txt() -> str:
        """
        Generate requirements.txt content for Redshift installer

        Returns:
            Requirements.txt content
        """
        return """click>=8.1.0
boto3>=1.26.0
python-dotenv>=1.0.0
redshift-connector>=2.0.0
sqlparse>=0.4.0
PyYAML>=6.0
jsonschema>=4.0.0
tqdm>=4.65.0
"""

    @staticmethod
    def create_installer_scripts(scripts_dir: Path, production: bool = False):
        """
        Create all Redshift installer scripts in the given directory

        Args:
            scripts_dir: Directory to create scripts in
            production: Deprecated - no longer used. Schema is always
                prompted interactively.
        """
        # Create install.py
        installer_py = RedshiftInstallerGenerator.generate_installer_py(production)
        install_script_path = scripts_dir / "install.py"
        with open(install_script_path, "w") as f:
            f.write(installer_py)
        install_script_path.chmod(0o755)

        # Create requirements.txt
        requirements = RedshiftInstallerGenerator.generate_requirements_txt()
        with open(scripts_dir / "requirements.txt", "w") as f:
            f.write(requirements)
