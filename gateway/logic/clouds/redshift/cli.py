"""
CLI for deploying Analytics Toolbox functions to Redshift
Handles Lambda deployments and external function creation
"""

import click
import sys
import subprocess
import os
from pathlib import Path
from typing import Optional, List, Set, Dict
from dotenv import load_dotenv

try:
    import redshift_connector

    HAS_REDSHIFT_CONNECTOR = True
except ImportError:
    HAS_REDSHIFT_CONNECTOR = False

# Add parent directories to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from common.engine import CatalogLoader, FunctionValidator, CloudType  # noqa: E402
from common.engine.packager import PackageBuilder  # noqa: E402
from common.utils import (  # noqa: E402
    get_default_function_roots,
    setup_logger,
    get_function_schema,
)

# Redshift-specific imports (moved from common/)
from validation.pre_flight_checks import run_pre_flight_checks  # noqa: E402
from template_renderer import TemplateRenderer  # noqa: E402

# Import LambdaDeployer and IAMRoleManager
platforms_path = (
    Path(__file__).parent.parent.parent / "platforms" / "aws-lambda" / "deploy"
)
sys.path.insert(0, str(platforms_path.parent))
from deploy.deployer import LambdaDeployer  # noqa: E402
from deploy.iam_manager import IAMRoleManager  # noqa: E402


logger = setup_logger("redshift-cli")


def load_env_config():
    """Load configuration from .env file

    Looks for .env file in:
    1. Core root directory (../../..) - shared with clouds
    2. Gateway root directory (../..) - gateway-specific
    """
    gateway_root = Path(__file__).parent.parent.parent.parent
    core_root = gateway_root.parent

    # Try core .env first (shared with clouds)
    core_env = core_root / ".env"
    gateway_env = gateway_root / ".env"

    if core_env.exists():
        load_dotenv(core_env)
        logger.info(f"Loaded configuration from {core_env}")
        # Load gateway .env as well to override if needed
        if gateway_env.exists():
            load_dotenv(gateway_env, override=True)
            logger.info(f"Loaded additional configuration from {gateway_env}")
    elif gateway_env.exists():
        load_dotenv(gateway_env)
        logger.info(f"Loaded configuration from {gateway_env}")
    else:
        logger.warning(f".env file not found at {core_env} or {gateway_env}")
        logger.warning("Using default AWS credentials from environment")


def get_env_or_default(key: str, default: any = None) -> any:
    """Get environment variable or return default"""
    return os.getenv(key, default)


def get_aws_credentials():
    """
    Get AWS credentials from environment variables

    Supports multiple authentication methods:
    1. Explicit credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
    2. AWS Profile (AWS_PROFILE)
    3. Assume role (AWS_ASSUME_ROLE_ARN)
    4. Session token for temporary credentials (AWS_SESSION_TOKEN)

    Returns:
        Dict with credential parameters for LambdaDeployer
    """
    return {
        "access_key_id": get_env_or_default("AWS_ACCESS_KEY_ID"),
        "secret_access_key": get_env_or_default("AWS_SECRET_ACCESS_KEY"),
        "session_token": get_env_or_default("AWS_SESSION_TOKEN"),
        "role_arn": get_env_or_default("AWS_ASSUME_ROLE_ARN"),
    }


def get_cluster_identifier_and_region() -> tuple:
    """
    Extract Redshift cluster identifier and region from RS_HOST

    Returns:
        (cluster_identifier, region) or (None, None) if not available

    Example:
        RS_HOST=my-cluster.abc123.us-east-1.redshift.amazonaws.com
        Returns: ("my-cluster", "us-east-1")
    """
    rs_host = get_env_or_default("RS_HOST")
    if rs_host:
        # Format: cluster-name.account-hash.region.redshift.amazonaws.com
        # Example: my-cluster.abc123xyz.us-east-1.redshift.amazonaws.com
        parts = rs_host.split(".")
        if len(parts) >= 5 and "redshift" in rs_host:
            cluster_id = parts[0]
            region = parts[2]
            return cluster_id, region

    return None, None


def execute_redshift_sql_direct(
    sql: str,
    host: str,
    database: str,
    user: str,
    password: str,
) -> None:
    """
    Execute SQL statement(s) in Redshift using direct connection (like clouds)

    Supports multiple statements separated by semicolons.

    Args:
        sql: SQL statement(s) to execute (can contain multiple statements)
        host: Redshift host (cluster endpoint)
        database: Database name
        user: Database user
        password: Database password

    Raises:
        ImportError: If redshift_connector is not installed
        RuntimeError: If SQL execution fails
    """
    if not HAS_REDSHIFT_CONNECTOR:
        raise ImportError(
            "redshift_connector is required for direct connection. "
            "Install it with: pip install redshift_connector"
        )

    # Split SQL into individual statements (handle multiple statements)
    # Remove empty statements and strip whitespace
    statements = [stmt.strip() for stmt in sql.split(";") if stmt.strip()]

    with redshift_connector.connect(
        host=host,
        database=database,
        user=user,
        password=password,
        timeout=300,  # 5 minute timeout for long-running operations
    ) as conn:
        conn.autocommit = True
        with conn.cursor() as cursor:
            for i, statement in enumerate(statements, 1):
                logger.debug(f"Executing statement {i}/{len(statements)}")
                cursor.execute(statement)
                logger.debug(f"Statement {i}/{len(statements)} completed")

    logger.debug("SQL execution completed")


def deploy_external_function(
    function_name: str,
    lambda_arn: str,
    sql_template_path: Path,
    database: str,
    schema: str,
    iam_role_arn: str,
    host: str,
    user: str,
    password: str,
) -> None:
    """
    Deploy external function SQL to Redshift using direct connection

    Args:
        function_name: Name of the function
        lambda_arn: ARN of the Lambda function
        sql_template_path: Path to SQL template file
        database: Database name
        schema: Schema name
        iam_role_arn: IAM role ARN for Redshift to invoke Lambda
        host: Redshift host endpoint
        user: Database user
        password: Database password
    """
    # Render SQL template
    renderer = TemplateRenderer()
    sql = renderer.render_external_function(
        template_path=sql_template_path,
        function_name=function_name,
        lambda_arn=lambda_arn,
        iam_role_arn=iam_role_arn,
        schema=schema,
    )

    logger.debug(f"Creating external function {schema}.{function_name.upper()}...")
    logger.debug(f"SQL: {sql}")

    # Use direct connection
    execute_redshift_sql_direct(
        sql=sql,
        host=host,
        database=database,
        user=user,
        password=password,
    )

    logger.debug(f"✓ External function {schema}.{function_name.upper()} created")


def get_modified_functions(function_roots: List[Path]) -> Set[str]:
    """
    Get list of function names that have been modified in git diff against base branch.

    Compares current branch against origin/main (or main) to find modified files.
    If infrastructure files (Makefiles, logic/, platforms/) are modified,
    returns None to indicate ALL functions should be deployed.

    Similar to the pattern in clouds/redshift/common/list_functions.js

    Args:
        function_roots: List of paths to function directories

    Returns:
        Set of modified function names, or None if infrastructure changed
        (None means deploy ALL functions)
    """
    try:
        # Get git repository root
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            check=True,
        )
        git_root = Path(result.stdout.strip())
        logger.debug(f"Git repository root: {git_root}")

        # Determine base branch to compare against
        # Try origin/main first, fall back to main, then master
        base_branch = None
        for branch in ["origin/main", "main", "origin/master", "master"]:
            result = subprocess.run(
                ["git", "rev-parse", "--verify", branch],
                capture_output=True,
                text=True,
                cwd=git_root,
            )
            if result.returncode == 0:
                base_branch = branch
                break

        if not base_branch:
            logger.warning(
                "Could not determine base branch (tried origin/main, main). "
                "Deploying all functions."
            )
            return None

        logger.debug(f"Comparing against base branch: {base_branch}")

        # Get git diff against base branch (run from git root)
        result = subprocess.run(
            ["git", "diff", "--name-only", base_branch, "HEAD"],
            capture_output=True,
            text=True,
            check=True,
            cwd=git_root,
        )
        modified_files = result.stdout.strip().split("\n")

        if not modified_files or modified_files == [""]:
            logger.warning("No modified files found in git diff")
            return set()

        logger.debug(f"Found {len(modified_files)} modified files")

        # Infrastructure paths that trigger full deployment
        infrastructure_patterns = [
            "Makefile",
            "logic/",
            "platforms/",
            ".github/workflows/",
            "requirements.txt",
        ]

        # Check if infrastructure was modified
        for file_path in modified_files:
            for pattern in infrastructure_patterns:
                if pattern in file_path:
                    logger.info(
                        f"Infrastructure file modified: {file_path}\n"
                        f"Deploying ALL functions (infrastructure change detected)"
                    )
                    return None

        modified_functions = set()

        # Check if any modified files are in function directories
        # Git diff returns paths relative to repo root
        # Function roots are absolute paths
        for file_path_str in modified_files:
            # Convert git-relative path to absolute path
            abs_file_path = git_root / file_path_str

            # Check if file is within any function root
            for root in function_roots:
                try:
                    # Make root absolute if it isn't already
                    abs_root = root.resolve()

                    # Check if the file is within this function root
                    # Function structure: <root>/<module>/<function_name>/...
                    relative = abs_file_path.relative_to(abs_root)
                    parts = relative.parts

                    # Need at least module/function_name/file
                    if len(parts) >= 2:
                        function_name = parts[1]  # Second level is function name
                        modified_functions.add(function_name)
                        logger.debug(
                            f"Modified function detected: {function_name} "
                            f"(from {file_path_str})"
                        )
                except ValueError:
                    # Path is not relative to this root
                    continue

        return modified_functions

    except subprocess.CalledProcessError as e:
        logger.warning(f"Failed to get git diff: {e}")
        logger.warning("Deploying all functions as fallback")
        return None
    except FileNotFoundError:
        logger.warning("git command not found")
        logger.warning("Deploying all functions as fallback")
        return None


@click.group()
@click.option("--verbose", "-v", is_flag=True, help="Enable verbose logging")
@click.pass_context
def cli(ctx, verbose):
    """
    CARTO Analytics Toolbox - Redshift Deployment CLI

    Deploy Lambda functions and create external functions in Redshift.
    """
    ctx.ensure_object(dict)
    ctx.obj["verbose"] = verbose

    if verbose:
        logger.setLevel("DEBUG")


@cli.command()
@click.option("--aws-profile", help="AWS profile to use")
@click.option("--region", default="us-east-1", help="AWS region")
@click.option("--cluster-id", help="Redshift cluster identifier (optional)")
@click.option("--database", help="Database name (optional)")
@click.pass_context
def check(
    ctx,
    aws_profile: Optional[str],
    region: str,
    cluster_id: Optional[str],
    database: Optional[str],
):
    """Run pre-flight checks to validate deployment environment"""
    verbose = ctx.obj.get("verbose", False)

    success = run_pre_flight_checks(
        aws_profile=aws_profile,
        region=region,
        cluster_id=cluster_id,
        database=database,
        verbose=verbose,
    )

    if not success:
        sys.exit(1)


@cli.command()
@click.option(
    "--function-roots",
    type=click.Path(exists=True, path_type=Path),
    help="Path to functions directory",
)
@click.option(
    "--include-root",
    "include_roots",
    multiple=True,
    type=click.Path(exists=True, path_type=Path),
    help="Additional function roots to include (can be specified multiple times)",
)
@click.option("--cloud", default="redshift", help="Cloud platform (default: redshift)")
@click.option("--modules", help="Comma-separated list of modules to list")
@click.option("--functions", help="Comma-separated list of functions to list")
@click.pass_context
def list_functions(
    ctx,
    function_roots: Optional[Path],
    include_roots: tuple,
    cloud: str,
    modules: Optional[str],
    functions: Optional[str],
):
    """List all functions available for Redshift"""
    # Build list of function roots
    roots_list = []
    if function_roots:
        roots_list.append(function_roots)
    else:
        roots_list.append(get_default_function_roots())

    if include_roots:
        roots_list.extend(include_roots)
        logger.info(f"Including {len(include_roots)} additional function root(s)")

    logger.info(f"Loading functions from {len(roots_list)} root(s)")

    loader = CatalogLoader(roots_list)
    loader.load_catalog()

    # Start with cloud filter
    try:
        cloud_type = CloudType(cloud.lower())
    except ValueError:
        logger.error(
            f"Invalid cloud type: {cloud}. "
            f"Valid options: redshift, bigquery, snowflake, databricks"
        )
        sys.exit(1)

    filtered_functions = loader.get_functions_by_cloud(cloud_type)

    # Apply modules filter
    if modules:
        module_list = [m.strip() for m in modules.split(",")]
        filtered_functions = [f for f in filtered_functions if f.module in module_list]

    # Apply functions filter
    if functions:
        function_list = [f.strip() for f in functions.split(",")]
        filtered_functions = [f for f in filtered_functions if f.name in function_list]

    if not filtered_functions:
        logger.warning("No functions found matching filters")
        return

    logger.info(f"\nFound {len(filtered_functions)} {cloud} functions:\n")

    # Group by module
    by_module = {}
    for func in filtered_functions:
        module = func.module
        if module not in by_module:
            by_module[module] = []
        by_module[module].append(func)

    for module in sorted(by_module.keys()):
        click.echo(f"\n[{module}]")
        for func in sorted(by_module[module], key=lambda f: f.name):
            click.echo(f"  - {func.name}")


@cli.command()
@click.option(
    "--function-roots",
    type=click.Path(exists=True, path_type=Path),
    help="Path to functions directory",
)
@click.option(
    "--include-root",
    "include_roots",
    multiple=True,
    type=click.Path(exists=True, path_type=Path),
    help="Additional function roots to include (can be specified multiple times)",
)
@click.pass_context
def validate(ctx, function_roots: Optional[Path], include_roots: tuple):
    """Validate all function definitions"""
    # Build list of function roots
    roots_list = []
    if function_roots:
        roots_list.append(function_roots)
    else:
        roots_list.append(get_default_function_roots())

    if include_roots:
        roots_list.extend(include_roots)
        logger.info(f"Including {len(include_roots)} additional function root(s)")

    schema_path = get_function_schema()
    validator = FunctionValidator(schema_path)

    errors = []
    success_count = 0

    for root in roots_list:
        logger.info(f"Validating functions in: {root}")
        for yaml_file in root.rglob("function.yaml"):
            function_dir = yaml_file.parent
            function_name = function_dir.name

            try:
                validator.validate_function(function_dir)
                success_count += 1
                if ctx.obj["verbose"]:
                    logger.debug(f"✓ {function_name}")
            except Exception as e:
                errors.append((function_name, str(e)))
                logger.error(f"✗ {function_name}: {e}")

    if errors:
        logger.error(f"\n{len(errors)} function(s) failed validation")
        sys.exit(1)
    else:
        logger.info(f"✓ All {success_count} functions valid")


@cli.command()
@click.argument("function_name")
@click.option("--aws-profile", help="AWS profile to use")
@click.option("--region", default="us-east-1", help="AWS region")
@click.option(
    "--dry-run", is_flag=True, help="Show what would be deployed without deploying"
)
@click.pass_context
def deploy_lambda(
    ctx, function_name: str, aws_profile: Optional[str], region: str, dry_run: bool
):
    """Deploy a Lambda function for a specific Analytics Toolbox function"""
    # Load environment configuration
    load_env_config()

    function_roots = get_default_function_roots()
    loader = CatalogLoader(function_roots)
    loader.load_catalog()

    function = loader.get_function(function_name)
    if not function:
        logger.error(f"Function '{function_name}' not found")
        sys.exit(1)

    if not function.supports_cloud(CloudType.REDSHIFT):
        logger.error(f"Function '{function_name}' does not support Redshift")
        sys.exit(1)

    logger.info(f"Deploying Lambda for function: {function_name}")

    # Get cloud configuration
    cloud_config = function.get_cloud_config(CloudType.REDSHIFT)

    # Get settings from .env or use defaults
    aws_region = get_env_or_default("AWS_REGION", region)
    aws_prof = get_env_or_default("AWS_PROFILE", aws_profile) if aws_profile else None
    rs_lambda_prefix = get_env_or_default("RS_LAMBDA_PREFIX", "carto-at-")
    rs_lambda_execution_role = get_env_or_default("RS_LAMBDA_EXECUTION_ROLE")

    # Get AWS credentials
    aws_creds = get_aws_credentials()

    # Construct Lambda function name
    lambda_function_name = f"{rs_lambda_prefix}{function_name}"

    # Get Lambda configuration
    runtime = cloud_config.config.get("runtime", "python3.11")
    memory_size = cloud_config.config.get("memory_size", 512)
    timeout = cloud_config.config.get("timeout", 60)

    if dry_run:
        logger.info("[DRY RUN] Would deploy Lambda function:")
        logger.info(f"  Function Name: {lambda_function_name}")
        logger.info(f"  Region: {aws_region}")
        logger.info(f"  Code: {cloud_config.code_file}")
        logger.info(f"  Runtime: {runtime}")
        logger.info(f"  Memory: {memory_size} MB")
        logger.info(f"  Timeout: {timeout}s")
        return

    # Deploy Lambda using LambdaDeployer
    try:
        deployer = LambdaDeployer(
            region=aws_region,
            profile=aws_prof,
            rs_lambda_prefix=rs_lambda_prefix,
            **aws_creds,
        )

        # Get paths
        function_dir = function.function_path
        handler_file = function_dir / cloud_config.code_file
        requirements_file = (
            function_dir / cloud_config.requirements_file
            if cloud_config.requirements_file
            else function_dir / "requirements.txt"
        )

        if not handler_file.exists():
            logger.error(f"Handler file not found: {handler_file}")
            sys.exit(1)

        # Deploy
        response = deployer.deploy_function(
            function_name=lambda_function_name,
            handler_file=handler_file,
            requirements_file=requirements_file if requirements_file.exists() else None,
            handler=cloud_config.config.get("handler", "handler.lambda_handler"),
            runtime=runtime,
            memory_size=memory_size,
            timeout=timeout,
            description=function.description,
            role_arn=rs_lambda_execution_role,
            function_root=function.function_path,
        )

        logger.info(f"✓ Successfully deployed {lambda_function_name}")
        logger.info(f"  ARN: {response.get('FunctionArn')}")

    except Exception as e:
        logger.error(f"Failed to deploy Lambda: {e}")
        sys.exit(1)


@cli.command()
@click.option(
    "--config",
    type=click.Path(exists=True, path_type=Path),
    help="Path to deployment config file",
)
@click.option(
    "--include-root",
    "include_roots",
    multiple=True,
    type=click.Path(exists=True, path_type=Path),
    help="Additional function roots to include (can be specified multiple times)",
)
@click.option("--aws-profile", help="AWS profile to use")
@click.option("--region", default="us-east-1", help="AWS region")
@click.option("--cloud", default="redshift", help="Cloud platform (default: redshift)")
@click.option("--modules", help="Comma-separated list of modules to deploy")
@click.option("--functions", help="Comma-separated list of functions to deploy")
@click.option(
    "--diff", is_flag=True, help="Deploy only functions modified in git working tree"
)
@click.option(
    "--dry-run", is_flag=True, help="Show what would be deployed without deploying"
)
@click.option(
    "--production",
    is_flag=True,
    help="Deploy for production (use 'carto' schema instead of prefixed schema)",
)
@click.pass_context
def deploy_all(
    ctx,
    config: Optional[Path],
    include_roots: tuple,
    aws_profile: Optional[str],
    region: str,
    cloud: str,
    modules: Optional[str],
    functions: Optional[str],
    diff: bool,
    dry_run: bool,
    production: bool,
):
    """Deploy all Lambda functions and create external functions"""
    logger.info("Deploying Analytics Toolbox to Redshift")

    # Store production flag in context
    ctx.obj["production"] = production

    # Load from all function roots
    all_functions = []
    if include_roots:
        # If explicit roots provided, use only those
        roots_to_load = list(include_roots)
    else:
        # Otherwise use default
        roots_to_load = [get_default_function_roots()]

    for root in roots_to_load:
        loader = CatalogLoader(root)
        loader.load_catalog()
        all_functions.extend(loader.get_all_functions())

    # Start with cloud filter
    try:
        cloud_type = CloudType(cloud.lower())
    except ValueError:
        logger.error(
            f"Invalid cloud type: {cloud}. "
            f"Valid options: redshift, bigquery, snowflake, databricks"
        )
        sys.exit(1)

    to_deploy = [f for f in all_functions if f.supports_cloud(cloud_type)]

    # Apply modules filter
    if modules:
        module_list = [m.strip() for m in modules.split(",")]
        to_deploy = [f for f in to_deploy if f.module in module_list]
        logger.info(f"Filtering by modules: {', '.join(module_list)}")

    # Apply functions filter
    if functions:
        function_list = [f.strip() for f in functions.split(",")]
        to_deploy = [f for f in to_deploy if f.name in function_list]
        logger.info(f"Filtering by functions: {', '.join(function_list)}")

    # Apply git diff filter
    if diff:
        modified_functions = get_modified_functions(roots_to_load)
        if modified_functions is None:
            # Infrastructure changed - deploy all functions
            logger.info("Deploying ALL functions (infrastructure or fallback)")
        else:
            # Only deploy modified functions
            to_deploy = [f for f in to_deploy if f.name in modified_functions]
            logger.info(f"Filtering by git diff: {len(modified_functions)} modified")

    logger.info(f"Deploying {len(to_deploy)} functions")

    if not to_deploy:
        logger.warning("No functions to deploy")
        return

    # Load environment configuration
    load_env_config()

    # Get settings from .env or use defaults
    aws_region = get_env_or_default("AWS_REGION", region)
    # AWS_PROFILE is optional - boto3 will use
    # AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY from env
    aws_prof = get_env_or_default("AWS_PROFILE", aws_profile) if aws_profile else None
    rs_lambda_prefix = get_env_or_default("RS_LAMBDA_PREFIX", "carto-at-")

    if dry_run:
        logger.info("[DRY RUN] Would deploy:")
        for func in to_deploy:
            lambda_name = f"{rs_lambda_prefix}{func.name}"
            logger.info(f"  - {lambda_name} ({func.module})")
        return

    # Get Redshift configuration (direct connection)
    rs_host = get_env_or_default("RS_HOST")
    rs_password = get_env_or_default("RS_PASSWORD")
    rs_database = get_env_or_default("RS_DATABASE")
    rs_prefix = get_env_or_default("RS_PREFIX", "")
    rs_user = get_env_or_default("RS_USER")
    # RS_LAMBDA_INVOKE_ROLE can be comma-separated for role chaining (like clouds)
    # Redshift will assume roles in order: role1 assumes role2, role2 invokes Lambda
    rs_lambda_invoke_role = get_env_or_default("RS_LAMBDA_INVOKE_ROLE")
    rs_iam_role_arn = rs_lambda_invoke_role.strip() if rs_lambda_invoke_role else None

    # Calculate schema based on production flag (matches clouds pattern)
    # production=1: schema = "carto"
    # production=0: schema = "{prefix}carto" (e.g., "myname_carto")
    rs_schema_default = "carto"
    # Check if we're in production mode from context
    is_production = ctx.obj.get("production", False)
    if is_production:
        rs_schema = rs_schema_default
    else:
        rs_schema = (
            f"{rs_prefix}{rs_schema_default}" if rs_prefix else rs_schema_default
        )

    # Validate Redshift configuration for external function deployment
    deploy_external_functions = True

    if not rs_database or not rs_iam_role_arn:
        logger.warning(
            "Redshift configuration incomplete (RS_DATABASE, RS_LAMBDA_INVOKE_ROLE). "
            "Will deploy Lambda functions only, not external functions."
        )
        deploy_external_functions = False
    elif not (rs_host and rs_user and rs_password):
        logger.warning(
            "Redshift connection not configured. Need: RS_HOST, RS_USER, RS_PASSWORD\n"
            "Will deploy Lambda functions only, not external functions."
        )
        deploy_external_functions = False

    # Get Lambda execution role (optional - avoids needing IAM create role permissions)
    rs_lambda_execution_role = get_env_or_default("RS_LAMBDA_EXECUTION_ROLE")

    # Get AWS credentials
    aws_creds = get_aws_credentials()

    # Phase 0: Setup IAM role for Redshift to invoke Lambda
    # If RS_LAMBDA_INVOKE_ROLE not provided, auto-create role and attempt to
    # attach to cluster
    if not rs_iam_role_arn and deploy_external_functions:
        logger.info("\n=== Phase 0: Setting up Redshift IAM Role ===\n")
        logger.info(
            "RS_LAMBDA_INVOKE_ROLE not specified, will auto-create role for Redshift"
        )

        try:
            iam_manager = IAMRoleManager(region=aws_region)

            # Get AWS account ID
            lambda_account_id = iam_manager.get_account_id()

            # Generate role name from rs_lambda_prefix
            # Example: carto-at- → CartoATRedshiftInvokeRole
            role_name = (
                rs_lambda_prefix.replace("-", "_")
                .replace("_", " ")
                .title()
                .replace(" ", "")
                + "RedshiftInvokeRole"
            )
            role_name = role_name.replace("At", "AT")  # Keep AT as acronym

            logger.info(f"Creating role: {role_name}")

            # Create role (same-account by default)
            rs_iam_role_arn = iam_manager.get_or_create_redshift_invoke_role(
                role_name=role_name,
                lambda_account_id=lambda_account_id,
            )

            # Try to auto-attach to cluster
            cluster_id, region = get_cluster_identifier_and_region()
            if cluster_id:
                logger.info(f"Detected cluster: {cluster_id} (region: {region})")
                iam_manager.attach_role_to_cluster(cluster_id, rs_iam_role_arn)
            else:
                logger.info(
                    "ℹ Could not parse cluster identifier from RS_HOST\n"
                    "  Please manually attach the role to your Redshift cluster:\n"
                    "  AWS Console → Redshift → Clusters → Properties → "
                    "Manage IAM roles\n"
                    f"  Attach: {rs_iam_role_arn}"
                )

        except Exception as e:
            logger.error(f"Failed to create Redshift invoke role: {e}")
            logger.warning("Continuing with Lambda deployment only...")
            deploy_external_functions = False

    # Deploy all functions
    try:
        deployer = LambdaDeployer(
            region=aws_region,
            profile=aws_prof,
            rs_lambda_prefix=rs_lambda_prefix,
            **aws_creds,
        )

        lambda_success = 0
        external_success = 0
        failed_functions = []
        lambda_arns: Dict[str, str] = {}

        # Phase 1: Deploy Lambda functions
        logger.info("\n=== Phase 1: Deploying Lambda Functions ===\n")

        with click.progressbar(
            to_deploy,
            label=f"Deploying {len(to_deploy)} Lambda functions",
            show_pos=True,
            item_show_func=lambda f: f.name if f else None,
        ) as bar:
            for func in bar:
                try:
                    lambda_function_name = f"{rs_lambda_prefix}{func.name}"

                    # Get cloud configuration
                    cloud_config = func.get_cloud_config(CloudType.REDSHIFT)

                    # Get paths
                    handler_file = func.function_path / cloud_config.code_file
                    requirements_file = (
                        func.function_path / cloud_config.requirements_file
                        if cloud_config.requirements_file
                        else func.function_path / "requirements.txt"
                    )

                    if not handler_file.exists():
                        logger.error(
                            f"\n✗ {func.name}: Handler file not found: {handler_file}"
                        )
                        failed_functions.append(func.name)
                        continue

                    # Get Lambda configuration
                    runtime = cloud_config.config.get("runtime", "python3.11")
                    memory_size = cloud_config.config.get("memory_size", 512)
                    timeout = cloud_config.config.get("timeout", 60)

                    # Deploy Lambda
                    response = deployer.deploy_function(
                        function_name=lambda_function_name,
                        handler_file=handler_file,
                        requirements_file=(
                            requirements_file if requirements_file.exists() else None
                        ),
                        handler=cloud_config.config.get(
                            "handler", "handler.lambda_handler"
                        ),
                        runtime=runtime,
                        memory_size=memory_size,
                        timeout=timeout,
                        description=func.description,
                        role_arn=rs_lambda_execution_role,
                        function_root=func.function_path,
                    )

                    # Strip version number from ARN (e.g., :19) to use $LATEST
                    arn = response["FunctionArn"]
                    if ":" in arn and arn.split(":")[-1].isdigit():
                        arn = ":".join(arn.split(":")[:-1])
                    lambda_arns[func.name] = arn
                    lambda_success += 1

                    # Configure Lambda resource policy for Redshift invocation
                    if rs_iam_role_arn:
                        # For role chaining (comma-separated roles), only the last role
                        # in the chain invokes Lambda
                        roles = [r.strip() for r in rs_iam_role_arn.split(",")]
                        invoking_role = roles[-1]  # Last role invokes Lambda
                        deployer.add_redshift_invoke_permission(
                            function_name=lambda_function_name,
                            principal=invoking_role,
                        )

                except Exception as e:
                    logger.error(f"\n✗ {func.name}: {e}")
                    failed_functions.append(func.name)
                    # Fail fast - stop deployment on first error
                    logger.error(f"\nDeployment failed for {func.name}. Stopping.")
                    sys.exit(1)

        # Phase 2: Deploy external functions in Redshift
        if deploy_external_functions and lambda_arns:
            logger.info("\n=== Phase 2: Creating external functions in Redshift ===\n")

            # Create schema if it doesn't exist
            create_schema_sql = f"CREATE SCHEMA IF NOT EXISTS {rs_schema};"
            logger.info(f"Ensuring schema exists: {rs_schema}")
            try:
                execute_redshift_sql_direct(
                    sql=create_schema_sql,
                    host=rs_host,
                    database=rs_database,
                    user=rs_user,
                    password=rs_password,
                )
                logger.info(f"✓ Schema ready: {rs_schema}\n")
            except Exception as e:
                logger.error(f"✗ Failed to create schema {rs_schema}: {e}")
                logger.error("Cannot proceed with external function creation")
                # Don't exit - still count Lambda deployments as success

            # Filter functions that have external function templates
            functions_to_deploy = []
            for func in to_deploy:
                if func.name not in lambda_arns:
                    continue
                cloud_config = func.get_cloud_config(CloudType.REDSHIFT)
                if cloud_config.external_function_template:
                    functions_to_deploy.append(func)

            with click.progressbar(
                functions_to_deploy,
                label=f"Creating {len(functions_to_deploy)} external functions",
                show_pos=True,
                item_show_func=lambda f: f.name if f else None,
            ) as bar:
                for func in bar:
                    try:
                        # Get cloud configuration
                        cloud_config = func.get_cloud_config(CloudType.REDSHIFT)

                        # Check if function has external function template
                        template_file = cloud_config.external_function_template
                        sql_template_path = func.function_path / template_file
                        if not sql_template_path.exists():
                            logger.error(
                                f"\n✗ {func.name}: "
                                f"Template not found: {sql_template_path}"
                            )
                            continue

                        # Deploy external function
                        deploy_external_function(
                            function_name=func.name,
                            lambda_arn=lambda_arns[func.name],
                            sql_template_path=sql_template_path,
                            database=rs_database,
                            schema=rs_schema,
                            iam_role_arn=rs_iam_role_arn,
                            host=rs_host,
                            user=rs_user,
                            password=rs_password,
                        )

                        external_success += 1

                    except Exception as e:
                        logger.error(f"\n✗ {func.name}: {e}")
                        # Fail fast - stop deployment on first error
                        logger.error(
                            f"\nExternal function deployment failed for "
                            f"{func.name}. Stopping."
                        )
                        sys.exit(1)

        # Summary
        separator = "=" * 50
        logger.info(f"\n{separator}")
        logger.info("Deployment Summary:")
        logger.info(separator)
        logger.info("  Lambda functions:")
        logger.info(f"    ✓ Successful: {lambda_success}/{len(to_deploy)}")
        if deploy_external_functions:
            logger.info("  external functions:")
            logger.info(f"    ✓ Successful: {external_success}/{lambda_success}")
        if failed_functions:
            logger.error(f"  ✗ Failed: {', '.join(failed_functions)}")
            logger.error("\nDeployment failed: One or more functions failed to deploy")
            sys.exit(1)

    except Exception as e:
        logger.error(f"Deployment failed: {e}")
        sys.exit(1)


@cli.command()
@click.option(
    "--include-root",
    "include_roots",
    multiple=True,
    type=click.Path(exists=True, path_type=Path),
    help="Additional function roots to include (can be specified multiple times)",
)
@click.option("--aws-profile", help="AWS profile to use")
@click.option("--region", default="us-east-1", help="AWS region")
@click.option("--cloud", default="redshift", help="Cloud platform (default: redshift)")
@click.option("--modules", help="Comma-separated list of modules to remove")
@click.option("--functions", help="Comma-separated list of functions to remove")
@click.option(
    "--dry-run", is_flag=True, help="Show what would be removed without removing"
)
@click.option(
    "--production",
    is_flag=True,
    help="Remove from production (use 'carto' schema instead of prefixed schema)",
)
@click.option(
    "--drop-schema",
    is_flag=True,
    help="Drop entire schema with CASCADE (faster, removes all objects in schema)",
)
@click.pass_context
def remove_all(
    ctx,
    include_roots: tuple,
    aws_profile: Optional[str],
    region: str,
    cloud: str,
    modules: Optional[str],
    functions: Optional[str],
    dry_run: bool,
    production: bool,
    drop_schema: bool,
):
    """Remove Lambda functions and external functions from Redshift

    NOTE: This command does NOT delete IAM roles. Roles can be reused across
    deployments and should be managed separately.

    Use --drop-schema for CI environments to drop the entire schema with CASCADE.
    This is faster and cleaner than dropping individual functions.
    """
    logger.info("Removing Analytics Toolbox from Redshift")

    # Store production flag in context
    ctx.obj["production"] = production

    # Load from all function roots
    all_functions = []
    if include_roots:
        roots_to_load = list(include_roots)
    else:
        roots_to_load = [get_default_function_roots()]

    for root in roots_to_load:
        loader = CatalogLoader(root)
        loader.load_catalog()
        all_functions.extend(loader.get_all_functions())

    # Filter by cloud
    try:
        cloud_type = CloudType(cloud.lower())
    except ValueError:
        logger.error(
            f"Invalid cloud type: {cloud}. "
            f"Valid options: redshift, bigquery, snowflake, databricks"
        )
        sys.exit(1)

    to_remove = [f for f in all_functions if f.supports_cloud(cloud_type)]

    # Apply modules filter
    if modules:
        module_list = [m.strip() for m in modules.split(",")]
        to_remove = [f for f in to_remove if f.module in module_list]
        logger.info(f"Filtering by modules: {', '.join(module_list)}")

    # Apply functions filter
    if functions:
        function_list = [f.strip() for f in functions.split(",")]
        to_remove = [f for f in to_remove if f.name in function_list]
        logger.info(f"Filtering by functions: {', '.join(function_list)}")

    logger.info(f"Removing {len(to_remove)} functions")

    if not to_remove:
        logger.warning("No functions to remove")
        return

    # Load environment configuration
    load_env_config()

    # Get settings from .env
    aws_region = get_env_or_default("AWS_REGION", region)
    aws_prof = get_env_or_default("AWS_PROFILE", aws_profile) if aws_profile else None
    rs_lambda_prefix = get_env_or_default("RS_LAMBDA_PREFIX", "carto-at-")

    # Get Redshift configuration
    rs_host = get_env_or_default("RS_HOST")
    rs_password = get_env_or_default("RS_PASSWORD")
    rs_database = get_env_or_default("RS_DATABASE")
    rs_prefix = get_env_or_default("RS_PREFIX", "")
    rs_user = get_env_or_default("RS_USER")

    # Calculate schema
    rs_schema_default = "carto"
    is_production = ctx.obj.get("production", False)
    if is_production:
        rs_schema = rs_schema_default
    else:
        rs_schema = (
            f"{rs_prefix}{rs_schema_default}" if rs_prefix else rs_schema_default
        )

    if dry_run:
        logger.info("[DRY RUN] Would remove:")
        logger.info(f"\nLambda functions ({len(to_remove)}):")
        for func in to_remove:
            lambda_name = f"{rs_lambda_prefix}{func.name}"
            logger.info(f"  - {lambda_name}")

        if drop_schema:
            logger.info("\nSchema:")
            logger.info(f"  - DROP SCHEMA {rs_schema} CASCADE")
        else:
            # Count external functions
            external_count = sum(
                1
                for f in to_remove
                if f.get_cloud_config(CloudType.REDSHIFT).external_function_template
            )
            logger.info(f"\nExternal functions in {rs_schema} ({external_count}):")
            for func in to_remove:
                cloud_config = func.get_cloud_config(CloudType.REDSHIFT)
                if cloud_config.external_function_template:
                    logger.info(f"  - {rs_schema}.{func.name.upper()}")

        logger.info("\nNOTE: IAM roles will NOT be deleted (they can be reused)")
        return

    # Get AWS credentials
    aws_creds = get_aws_credentials()

    try:
        deployer = LambdaDeployer(
            region=aws_region,
            profile=aws_prof,
            rs_lambda_prefix=rs_lambda_prefix,
            **aws_creds,
        )

        lambda_success = 0
        external_success = 0
        failed_functions = []

        # Phase 1: Drop all functions from Redshift
        if rs_host and rs_user and rs_password and rs_database:
            logger.info("\n=== Phase 1: Dropping from Redshift ===\n")

            # Filter functions that have external function templates
            functions_to_drop = [
                f
                for f in to_remove
                if f.get_cloud_config(CloudType.REDSHIFT).external_function_template
            ]

            if drop_schema:
                # Drop entire schema with CASCADE - faster and cleaner for CI
                try:
                    logger.info(f"Dropping schema {rs_schema} with CASCADE...")
                    drop_schema_sql = f"DROP SCHEMA IF EXISTS {rs_schema} CASCADE"

                    with redshift_connector.connect(
                        host=rs_host,
                        database=rs_database,
                        user=rs_user,
                        password=rs_password,
                        timeout=300,
                    ) as conn:
                        conn.autocommit = True
                        with conn.cursor() as cursor:
                            cursor.execute(drop_schema_sql)

                    logger.info(f"✓ Dropped schema {rs_schema} (all objects removed)\n")
                    external_success = len(functions_to_drop)
                except Exception as e:
                    logger.error(f"✗ Failed to drop schema: {e}\n")
                    # Continue with Lambda deletion even if schema drop fails
            elif functions_to_drop:
                try:
                    # Drop ALL external functions (Lambda-backed) in the schema
                    # Gateway only deploys external functions, so this is safe
                    # Uses the same pattern as DROP_FUNCTIONS.sql in clouds
                    create_table_proc = f"""CREATE OR REPLACE PROCEDURE {rs_schema}.__create_drop_table_gw()  # noqa: E501
AS $$
DECLARE
  row RECORD;
BEGIN
  DROP TABLE IF EXISTS _gw_udfs_info;
  CREATE TEMP TABLE _gw_udfs_info (f_oid BIGINT, f_kind VARCHAR(1), f_name VARCHAR(MAX), arg_index BIGINT, f_argtype VARCHAR(MAX));  # noqa: E501
  FOR row IN SELECT oid::BIGINT f_oid, kind::VARCHAR(1) f_kind, proname::VARCHAR(MAX) f_name, i arg_index, format_type(arg_types[i-1], null)::VARCHAR(MAX) f_argtype  # noqa: E501
    FROM (
      SELECT oid, kind, proname, generate_series(1, arg_count) AS i, arg_types
      FROM (
        SELECT p.prooid oid, p.prokind kind, proname, proargtypes arg_types, pronargs arg_count  # noqa: E501
        FROM pg_catalog.pg_namespace n
        JOIN PG_PROC_INFO p ON pronamespace = n.oid
        WHERE nspname = '{rs_schema}'
      ) t
    ) t
  LOOP
    INSERT INTO _gw_udfs_info(f_oid, f_kind, f_name, arg_index, f_argtype)
    VALUES (row.f_oid, row.f_kind, row.f_name, row.arg_index, row.f_argtype);
  END LOOP;
END;
$$ LANGUAGE plpgsql"""

                    drop_functions_proc = f"""CREATE OR REPLACE PROCEDURE {rs_schema}.__drop_gateway_functions()  # noqa: E501
AS $$
DECLARE
    row RECORD;
BEGIN
    CALL {rs_schema}.__create_drop_table_gw();

    FOR row IN SELECT drop_command
    FROM (
        SELECT 'DROP ' || CASE f_kind WHEN 'p' THEN 'PROCEDURE' ELSE 'FUNCTION' END ||  # noqa: E501
               ' {rs_schema}.' || f_name || '(' ||
               listagg(f_argtype,',' ) WITHIN GROUP (ORDER BY arg_index) || ');' AS drop_command  # noqa: E501
        FROM _gw_udfs_info
        GROUP BY f_oid, f_name, f_kind
    )
    LOOP
        EXECUTE row.drop_command;
    END LOOP;

    DROP TABLE IF EXISTS _gw_udfs_info;
END;
$$ LANGUAGE plpgsql"""

                    with redshift_connector.connect(
                        host=rs_host,
                        database=rs_database,
                        user=rs_user,
                        password=rs_password,
                        timeout=300,
                    ) as conn:
                        conn.autocommit = True
                        with conn.cursor() as cursor:
                            # Create helper procedure
                            cursor.execute(create_table_proc)

                            # Create main drop procedure
                            cursor.execute(drop_functions_proc)

                            # Call procedure to drop functions
                            cursor.execute(
                                f"CALL {rs_schema}.__drop_gateway_functions()"
                            )

                            # Clean up temporary procedures
                            cursor.execute(
                                f"DROP PROCEDURE {rs_schema}.__create_drop_table_gw()"
                            )
                            cursor.execute(
                                f"DROP PROCEDURE {rs_schema}.__drop_gateway_functions()"
                            )

                    logger.info(f"✓ Dropped all functions in schema {rs_schema}\n")
                except Exception as e:
                    logger.error(f"✗ Failed to drop functions: {e}\n")
                    # Continue with Lambda deletion even if Redshift drop fails

                external_success = len(functions_to_drop)
            else:
                logger.info("No external functions to drop\n")
        else:
            logger.warning(
                "Redshift connection not configured. "
                "Skipping external function removal.\n"
            )

        # Phase 2: Delete Lambda functions
        logger.info("=== Phase 2: Deleting Lambda functions ===\n")

        with click.progressbar(
            to_remove,
            label=f"Deleting {len(to_remove)} Lambda functions",
            show_pos=True,
            item_show_func=lambda f: f.name if f else None,
        ) as bar:
            for func in bar:
                try:
                    lambda_function_name = f"{rs_lambda_prefix}{func.name}"
                    deployer.delete_function(lambda_function_name)
                    lambda_success += 1
                except Exception as e:
                    # Don't fail if function doesn't exist
                    if "ResourceNotFoundException" not in str(e):
                        logger.error(f"\n✗ {func.name}: {e}")
                        if func.name not in failed_functions:
                            failed_functions.append(func.name)

        # Summary
        separator = "=" * 50
        logger.info(f"\n{separator}")
        logger.info("Removal Summary:")
        logger.info(separator)
        logger.info("  Lambda functions:")
        logger.info(f"    ✓ Deleted: {lambda_success}/{len(to_remove)}")
        if rs_host and functions_to_drop:
            logger.info("  External functions:")
            logger.info(f"    ✓ Dropped: {external_success}/{len(functions_to_drop)}")
        if failed_functions:
            logger.warning(f"  ✗ Failed: {', '.join(failed_functions)}")

        logger.info(
            "\nNOTE: IAM roles were NOT deleted "
            "(they can be reused for future deployments)"  # noqa: E501
        )
        logger.info("      To delete roles manually, use AWS Console or AWS CLI")

    except Exception as e:
        logger.error(f"Removal failed: {e}")
        sys.exit(1)


@cli.command()
@click.argument("output_dir", type=click.Path(path_type=Path))
@click.option("--version", required=True, help="Version string for the package")
@click.option(
    "--include-root",
    "include_roots",
    multiple=True,
    type=click.Path(exists=True, path_type=Path),
    help="Additional function roots to include (can be specified multiple times)",
)
@click.option(
    "--functions", help="Comma-separated list of functions to include (default: all)"
)
@click.option(
    "--production",
    is_flag=True,
    help="Generate installer for production (skip schema prefix prompt)",
)
@click.pass_context
def create_package(
    ctx,
    output_dir: Path,
    version: str,
    include_roots: tuple,
    functions: Optional[str],
    production: bool,
):
    """Create a distribution package for customer installation"""
    logger.info(f"Creating distribution package: version {version}")

    # Load from all function roots
    function_roots = [get_default_function_roots()]
    if include_roots:
        function_roots.extend(include_roots)
        logger.info(f"Including {len(include_roots)} additional function root(s)")

    loader = CatalogLoader(function_roots)
    loader.load_catalog()

    # Get functions to include
    if functions:
        function_names = [f.strip() for f in functions.split(",")]
        to_include = [loader.get_function(name) for name in function_names]
        to_include = [f for f in to_include if f is not None]
    else:
        to_include = loader.get_functions_by_cloud(CloudType.REDSHIFT)

    logger.info(f"Including {len(to_include)} functions")

    output_dir.mkdir(parents=True, exist_ok=True)

    # Create package using PackageBuilder
    builder = PackageBuilder(version, CloudType.REDSHIFT)
    package_path = builder.create_package(to_include, output_dir, production)

    logger.info(f"✓ Package created: {package_path}")


if __name__ == "__main__":
    cli(obj={})
