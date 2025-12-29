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
        self._create_version_file(package_dir)
        self._create_documentation(package_dir, functions)
        self._apply_extra_customizations(package_dir, production, functions)

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

        # Copy the entire logic directory structure (excluding tests)
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
                "tests",  # Exclude all test directories
                "conftest.py",  # Exclude pytest config files
                "dist",  # Exclude dist directories (prevents recursive copying)
            ),
        )

        # Copy functions directory (only selected functions)
        functions_dst = package_dir / "functions"
        ensure_dir(functions_dst)

        # Copy only the functions we're deploying
        # Functions may come from multiple roots (core + private)
        # Preserve the module/function structure: functions/<module>/<function_name>
        for func in functions:
            func_src = Path(func.function_path)
            if func_src.exists():
                # Reconstruct path as: functions/<module>/<function_name>
                func_dst = functions_dst / func.module / func.name
                # Create parent directories
                func_dst.parent.mkdir(parents=True, exist_ok=True)
                # Copy entire function directory (excluding tests and docs)
                if func_src.is_dir():
                    shutil.copytree(
                        func_src,
                        func_dst,
                        ignore=shutil.ignore_patterns(
                            "__pycache__",
                            "*.pyc",
                            "*.pyo",
                            ".pytest_cache",
                            "tests",  # Exclude test directories
                            # Exclude function READMEs (main README in package)
                            "README.md",
                            "*.md",  # Exclude all markdown files from functions
                        ),
                    )

                    # Copy shared libraries if specified in function.yaml
                    self._copy_shared_libs(func, func_dst, gateway_root)

        logger.info(
            f"Copied deployment logic and {len(functions)} function definitions"
        )

    def _copy_shared_libs(self, func: Function, func_dst: Path, gateway_root: Path):
        """
        Copy shared libraries into function's deployment package.

        Supports two formats:
        1. Module name: "data" - copies entire _shared/python/data/
           directory
        2. File paths: "data/_utils.py", "data/__init__.py" - copies
           only specified files

        Shared libraries are defined in function.yaml under 'shared_libs'.
        They are copied from functions/_shared/python/ to the function's lib/ directory.

        Args:
            func: Function object
            func_dst: Destination directory for the function
            gateway_root: Gateway root directory
        """
        # Load function.yaml to get shared_libs configuration
        import yaml

        yaml_path = func.function_path / "function.yaml"
        if not yaml_path.exists():
            return  # No function.yaml, nothing to do

        with open(yaml_path, "r") as f:
            config = yaml.safe_load(f)

        # Check if function has shared_libs configuration for this cloud
        cloud_config = config.get("clouds", {}).get(self.cloud.value, {})
        shared_libs = cloud_config.get("shared_libs", [])

        if not shared_libs:
            return  # No shared libraries to copy

        # Determine the correct gateway root from the function's location
        # Functions can come from multiple roots (core + private)
        # Function path: /path/to/gateway/functions/module/function_name
        # Gateway root: /path/to/gateway
        func_gateway_root = func.function_path.parent.parent.parent
        shared_root = func_gateway_root / "functions" / "_shared" / "python"

        if not shared_root.exists():
            logger.warning(
                f"Shared libraries directory not found: {shared_root} "
                f"(derived from function path: {func.function_path})"
            )
            return

        # Track which files have been added per module (to ensure __init__.py)
        modules_with_files = set()
        init_files_added = set()

        for lib_name in shared_libs:
            # Check if this is a path (contains /)
            if "/" in lib_name:
                # Path format: "data/_utils.py" (file) or "data/utils/" (folder)
                parts = lib_name.split("/", 1)
                module_name = parts[0]
                sub_path = parts[1] if len(parts) > 1 else ""

                modules_with_files.add(module_name)

                lib_src = shared_root / lib_name
                if not lib_src.exists():
                    logger.warning(f"Shared library path not found: {lib_name}")
                    continue

                if lib_src.is_file():
                    # Copy single file: data/_utils.py -> lib/data/_utils.py
                    # Construct path explicitly by splitting on "/" for
                    # proper subdirectory handling
                    lib_base = func_dst / "code" / "lambda" / "python" / "lib"

                    # Build path from parts to ensure proper directory nesting
                    lib_dst = lib_base
                    for part in lib_name.split("/"):
                        lib_dst = lib_dst / part

                    # Ensure parent directory exists
                    lib_dst.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(lib_src, lib_dst)

                    # Track if this was __init__.py
                    if sub_path == "__init__.py":
                        init_files_added.add(module_name)

                    logger.debug(f"  Copied shared lib file: {lib_name}")

                elif lib_src.is_dir():
                    # Copy entire subdirectory: data/utils/ -> lib/data/utils/
                    # Construct path explicitly by splitting on "/" for
                    # proper subdirectory handling
                    lib_base = func_dst / "code" / "lambda" / "python" / "lib"

                    # Build path from parts to ensure proper directory nesting
                    lib_dst = lib_base
                    for part in lib_name.split("/"):
                        lib_dst = lib_dst / part

                    if lib_dst.exists():
                        shutil.rmtree(lib_dst)
                    shutil.copytree(
                        lib_src,
                        lib_dst,
                        ignore=shutil.ignore_patterns("__pycache__", "*.pyc", "tests"),
                    )
                    logger.debug(f"  Copied shared lib folder: {lib_name}")
                else:
                    logger.warning(f"  {lib_name} is neither a file nor directory")

            else:
                # Module name format: "data" - copy entire directory
                # (backward compatible)
                lib_src = shared_root / lib_name

                if lib_src.is_dir():
                    # Copy entire directory (e.g., "data" -> lib/data/)
                    lib_dst = func_dst / "code" / "lambda" / "python" / "lib" / lib_name
                    if lib_dst.exists():
                        shutil.rmtree(lib_dst)
                    shutil.copytree(
                        lib_src,
                        lib_dst,
                        ignore=shutil.ignore_patterns("__pycache__", "*.pyc", "tests"),
                    )
                    logger.debug(f"  Copied shared lib: {lib_name}/ -> lib/{lib_name}/")
                    # Mark __init__.py as added for this module
                    init_files_added.add(lib_name)

                elif lib_src.is_file() or (lib_src.parent / f"{lib_name}.py").is_file():
                    # Copy single file
                    # (e.g., "placekey/placekey.py" -> lib/placekey/placekey.py)
                    if not lib_src.is_file():
                        lib_src = lib_src.parent / f"{lib_name}.py"

                    lib_dst = (
                        func_dst / "code" / "lambda" / "python" / "lib" / lib_src.name
                    )
                    lib_dst.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(lib_src, lib_dst)
                    logger.debug(
                        f"  Copied shared lib: {lib_name} -> lib/{lib_src.name}"
                    )
                else:
                    logger.warning(
                        f"  Shared library not found: {lib_name} in {shared_root}"
                    )

        # Ensure __init__.py is present for modules that had individual files added
        for module_name in modules_with_files:
            if module_name not in init_files_added:
                init_src = shared_root / module_name / "__init__.py"
                if init_src.exists():
                    # Construct path explicitly for proper subdirectory handling
                    lib_dst = (
                        func_dst
                        / "code"
                        / "lambda"
                        / "python"
                        / "lib"
                        / module_name
                        / "__init__.py"
                    )

                    lib_dst.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(init_src, lib_dst)
                    logger.debug(f"  Copied required __init__.py for {module_name}/")

    def _create_version_file(self, package_dir: Path):
        """
        Create version file in package for version tracking.

        Creates clouds/{cloud}/version file so the CLI can read package version
        even if the package ZIP file is renamed by users.

        Args:
            package_dir: Package directory
        """
        # Create clouds/redshift/version (or other cloud)
        version_dir = ensure_dir(package_dir / "clouds" / self.cloud.value)
        version_file = version_dir / "version"

        with open(version_file, "w") as f:
            f.write(f"{self.version}\n")

        logger.info(f"Created version file: {self.version}")

    def _create_scripts_dir(self, package_dir: Path, production: bool):
        """
        Create installation scripts using core installer generator

        Args:
            package_dir: Package directory
            production: Whether installer is for production mode
        """
        scripts_dir = ensure_dir(package_dir / "scripts")

        # Delegate to cloud-specific installer generator
        if self.cloud == CloudType.REDSHIFT:
            # Dynamic import to support both module and CLI execution
            try:
                # Try absolute import first (for module usage)
                from logic.clouds.redshift.installer_generator import (
                    RedshiftInstallerGenerator,
                )
            except ModuleNotFoundError:
                # Fall back to relative import (for CLI usage)
                import sys

                # Add gateway root to path
                gateway_root = get_gateway_root()
                if str(gateway_root) not in sys.path:
                    sys.path.insert(0, str(gateway_root))

                from logic.clouds.redshift.installer_generator import (
                    RedshiftInstallerGenerator,
                )

            RedshiftInstallerGenerator.create_installer_scripts(scripts_dir, production)
            logger.info("Using core installer")
        else:
            # Future clouds can add their own installer generators here
            raise NotImplementedError(
                f"Installer generation not implemented for {self.cloud.value}"
            )

    def _find_package_customizer(self, cloud: str):
        """
        Look for extra packager customization function in extended repository.

        Uses convention-based path: ../../gateway/logic/clouds/{cloud}/packager.py
        Expects function: customize_package(package_dir, production, functions)

        Returns:
            Callable if found, None otherwise
        """
        try:
            import importlib.util

            # Calculate path to potential extra packager
            # From: core/gateway/logic/common/engine/packager.py
            # To: gateway/logic/clouds/{cloud}/packager.py
            repo_root = get_gateway_root().parent.parent
            extra_packager_path = (
                repo_root / "gateway" / "logic" / "clouds" / cloud / "packager.py"
            )

            if not extra_packager_path.exists():
                logger.debug(f"No extra packager at: {extra_packager_path}")
                return None

            # Load module from file
            spec = importlib.util.spec_from_file_location(
                "extra_packager", str(extra_packager_path)
            )
            extra_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(extra_module)

            # Look for standard function name
            if hasattr(extra_module, "customize_package"):
                logger.debug(f"Found extra packager at: {extra_packager_path}")
                return extra_module.customize_package

            logger.warning(
                f"Extra packager missing customize_package(): {extra_packager_path}"
            )
            return None

        except Exception as e:
            logger.debug(f"Error loading extra packager: {e}")
            return None

    def _apply_extra_customizations(
        self, package_dir: Path, production: bool, functions: List[Function]
    ):
        """
        Apply extra customizations to package if available

        Looks for extra packager override that can customize package contents
        (scripts, README, etc.). Falls back to core scripts-only behavior if
        no extra packager found.

        Args:
            package_dir: Root directory of the package to customize
            production: Whether package is for production mode
            functions: List of functions being packaged
        """
        if self.cloud == CloudType.REDSHIFT:
            customization_applied = False
            extra_customizer = self._find_package_customizer("redshift")

            if extra_customizer:
                try:
                    extra_customizer(package_dir, production, functions)
                    logger.info("Using extra packager")
                    customization_applied = True
                except Exception as e:
                    logger.warning(f"Extra packager failed: {e}, using core")

            if not customization_applied:
                # Fall back to core behavior: just create scripts
                self._create_scripts_dir(package_dir, production)

    def _create_documentation(self, package_dir: Path, functions: List[Function]):
        """Create README and documentation"""
        readme_content = f"""# CARTO Analytics Toolbox for Redshift

Version: {self.version}

## Quick Start

```bash
# 1. Extract the package (if not auto-extracted by your browser)
unzip carto-at-{self.cloud.value}-{self.version}.zip

# 2. Navigate to package directory
cd carto-at-{self.cloud.value}-{self.version}

# 3. Setup Python environment
python3 -m venv .venv && source .venv/bin/activate
pip install -r scripts/requirements.txt

# 4. Run interactive installer
python scripts/install.py
```

**Note**: On macOS, browsers may auto-extract the ZIP. If the folder already exists, skip step 1.

## Prerequisites

- **Python**: 3.10+ (tested with 3.10-3.13)
- **AWS**: Account with Lambda and IAM permissions
- **Redshift**: Cluster with admin access

## Installation Methods

### Option 1: Interactive Installation (Recommended)

The installer guides you through configuration with prompts:

```bash
python scripts/install.py
```

**Deployment Phases:**
- **Phase 0** (if needed): Auto-creates IAM roles (Lambda execution + Redshift invoke)
- **Phase 1**: Deploys Lambda functions to AWS
- **Phase 2**: Creates external functions in Redshift
- **Phase 3**: Deploys native SQL UDFs

### Option 2: Non-Interactive Installation

For automated deployments (CI/CD, scripts), use the `--non-interactive` flag:

```bash
python scripts/install.py \\
  --non-interactive \\
  --aws-region us-east-1 \\
  --aws-access-key-id AKIAXXXX \\
  --aws-secret-access-key XXXX \\
  --rs-lambda-prefix mycompany- \\
  --rs-host cluster.region.redshift.amazonaws.com \\
  --rs-database mydb \\
  --rs-user myuser \\
  --rs-password "secret" \\
  --rs-schema myschema
```

**Important**: The `--non-interactive` (or `-y`) flag is **required** to skip prompts.
Without it, the installer will always prompt interactively, even if all parameters
are provided via command line.

### Get Help

See all available options:

```bash
python scripts/install.py --help
```

## CLI Parameters Reference

### AWS Authentication (Choose one method)

**Method 1: AWS Profile** (Recommended)
```bash
--aws-profile default
```

**Method 2: Explicit Credentials**
```bash
--aws-access-key-id AKIAXXXX
--aws-secret-access-key XXXX
--aws-session-token XXXX  # Optional, for temporary credentials
```

**Method 3: IAM Role** (No parameters needed - automatic on EC2/ECS)

**Method 4: Assume Role** (Cross-account)
```bash
--aws-assume-role-arn arn:aws:iam::ACCOUNT:role/ROLE
```

### AWS Configuration

- `--aws-region TEXT`: AWS region (default: us-east-1)

### Lambda Configuration

- `--rs-lambda-prefix TEXT`: Lambda name prefix (default: carto-at-)
  - Example: `mycompany-` → Functions named `mycompany-function_name`
  - Role names: `MycompanyLambdaExecutionRole`, `MycompanyRedshiftInvokeRole`
- `--rs-lambda-execution-role TEXT`: Existing Lambda execution role ARN (optional)
  - If not provided, will auto-create during Phase 0
- `--rs-lambda-override / --no-rs-lambda-override`: Override existing Lambdas
  (default: yes)

### Redshift Configuration

- `--rs-host TEXT`: Redshift host endpoint (**required**)
  - Example: `cluster.abc123.us-east-1.redshift.amazonaws.com`
- `--rs-database TEXT`: Redshift database name (**required**)
- `--rs-user TEXT`: Redshift username (**required**)
- `--rs-password TEXT`: Redshift password (**required**)
- `--rs-schema TEXT`: Schema for Analytics Toolbox functions (default: carto)
  - Functions will be created in this schema
- `--rs-lambda-invoke-role TEXT`: Existing Redshift IAM role ARN (optional)
  - If not provided, will auto-create and attach to cluster during Phase 0
  - Can be comma-separated for role chaining

## IAM Roles

When IAM role ARNs are not provided, the installer will automatically create
them during Phase 0.

### Lambda Execution Role

- **Purpose**: Allows Lambda functions to execute and log
- **Name**: `<Prefix>LambdaExecutionRole` (e.g., `CartoATLambdaExecutionRole`)
- **Trust Policy**: Trusts `lambda.amazonaws.com`
- **Permissions**: `AWSLambdaBasicExecutionRole` (CloudWatch Logs)

### Redshift Invoke Role

- **Purpose**: Allows Redshift to invoke Lambda functions
- **Name**: `<Prefix>RedshiftInvokeRole` (e.g., `CartoATRedshiftInvokeRole`)
- **Trust Policy**: Trusts `redshift.amazonaws.com`
- **Permissions**: `lambda:InvokeFunction` on all Lambda functions
- **Auto-attached**: To Redshift cluster (if permissions available)

### Using Existing Roles

To use pre-created roles instead of auto-creation:

```bash
python scripts/install.py \\
  --rs-lambda-execution-role arn:aws:iam::ACCOUNT:role/MyLambdaRole \\
  --rs-lambda-invoke-role arn:aws:iam::ACCOUNT:role/MyRedshiftRole \\
  ...
```

## Required AWS Permissions

**For Auto-Creation (Full Install)**:
- `lambda:CreateFunction`, `lambda:UpdateFunctionCode`,
  `lambda:UpdateFunctionConfiguration`
- `lambda:GetFunction`, `lambda:AddPermission`
- `iam:CreateRole`, `iam:GetRole`, `iam:PutRolePolicy`, `iam:AttachRolePolicy`
- `redshift:DescribeClusters`, `redshift:ModifyClusterIamRoles`

**For Existing Roles (Minimal)**:
- `lambda:CreateFunction`, `lambda:UpdateFunctionCode`,
  `lambda:UpdateFunctionConfiguration`
- `lambda:GetFunction`, `lambda:AddPermission`

## Examples

**Interactive Mode** (default - with prompts):
```bash
python scripts/install.py
```

**Non-Interactive with Auto-Created Roles**:
```bash
python scripts/install.py \\
  --non-interactive \\
  --aws-profile dev \\
  --rs-lambda-prefix mycompany- \\
  --rs-host cluster.region.redshift.amazonaws.com \\
  --rs-database mydb \\
  --rs-user myuser \\
  --rs-password "secret" \\
  --rs-schema myschema
```

**Non-Interactive with Existing Roles**:
```bash
python scripts/install.py \\
  --non-interactive \\
  --aws-profile prod \\
  --rs-lambda-prefix carto-at- \\
  --rs-lambda-execution-role arn:aws:iam::123:role/ProdLambdaRole \\
  --rs-lambda-invoke-role arn:aws:iam::123:role/ProdRedshiftRole \\
  --rs-host cluster.region.redshift.amazonaws.com \\
  --rs-database prod_db \\
  --rs-user produser \\
  --rs-password "secret" \\
  --rs-schema carto
```

**Non-Interactive with Explicit Credentials**:
```bash
python scripts/install.py \\
  --non-interactive \\
  --aws-access-key-id $AWS_ACCESS_KEY_ID \\
  --aws-secret-access-key $AWS_SECRET_ACCESS_KEY \\
  --rs-lambda-prefix myprefix- \\
  --rs-host $REDSHIFT_HOST \\
  --rs-database $REDSHIFT_DB \\
  --rs-user $REDSHIFT_USER \\
  --rs-password "$REDSHIFT_PASSWORD" \\
  --rs-schema myschema
```

## Support

- **Documentation**: https://docs.carto.com/analytics-toolbox
- **Support**: support@carto.com
- **GitHub**: https://github.com/CartoDB/analytics-toolbox
"""

        with open(package_dir / "README.md", "w") as f:
            f.write(readme_content)

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
