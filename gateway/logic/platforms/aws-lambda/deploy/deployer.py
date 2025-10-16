"""
AWS Lambda deployment utilities
Handles packaging and deploying Lambda functions
"""

import boto3
import zipfile
import tempfile
import subprocess
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional, Any
import hashlib
import re


class LambdaDeployer:
    """Deploys Lambda functions to AWS"""

    def __init__(
        self,
        region: str = "us-east-1",
        profile: Optional[str] = None,
        access_key_id: Optional[str] = None,
        secret_access_key: Optional[str] = None,
        session_token: Optional[str] = None,
        role_arn: Optional[str] = None,
        rs_lambda_prefix: str = "carto-at-",
    ):
        """
        Initialize Lambda deployer with flexible credential options

        Credential priority order:
        1. Explicit credentials (access_key_id + secret_access_key)
        2. Assume role (role_arn)
        3. AWS profile (profile)
        4. Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
        5. IAM role (if running on EC2/ECS/Lambda)

        Args:
            region: AWS region
            profile: AWS profile name
            access_key_id: AWS access key ID
            secret_access_key: AWS secret access key
            session_token: AWS session token (for temporary credentials)
            role_arn: IAM role ARN to assume
            rs_lambda_prefix: Lambda function prefix (default: "carto-at-")
        """
        self.rs_lambda_prefix = rs_lambda_prefix
        session_kwargs = {"region_name": region}

        # Method 1: Explicit credentials (highest priority)
        if access_key_id and secret_access_key:
            session_kwargs["aws_access_key_id"] = access_key_id
            session_kwargs["aws_secret_access_key"] = secret_access_key
            if session_token:
                session_kwargs["aws_session_token"] = session_token
            print(
                f"Using explicit AWS credentials (access key: {access_key_id[:8]}...)"
            )

        # Method 2: AWS Profile
        elif profile:
            session_kwargs["profile_name"] = profile
            print(f"Using AWS profile: {profile}")

        # Method 3: Environment variables / IAM role (boto3 handles automatically)
        else:
            print("Using default AWS credential chain (env vars or IAM role)")

        session = boto3.Session(**session_kwargs)

        # Method 4: Assume Role (if specified)
        if role_arn:
            print(f"Assuming IAM role: {role_arn}")
            sts = session.client("sts")
            try:
                # Session name: carto_at_deployer
                # (replace hyphens with underscores, max 64 chars)
                session_name = f"{self.rs_lambda_prefix}deployer".replace("-", "_")[:64]
                assumed_role = sts.assume_role(
                    RoleArn=role_arn, RoleSessionName=session_name
                )
                credentials = assumed_role["Credentials"]
                session = boto3.Session(
                    aws_access_key_id=credentials["AccessKeyId"],
                    aws_secret_access_key=credentials["SecretAccessKey"],
                    aws_session_token=credentials["SessionToken"],
                    region_name=region,
                )
                print(f"✓ Successfully assumed role: {role_arn}")
            except Exception as e:
                raise Exception(f"Failed to assume role {role_arn}: {e}")

        self.lambda_client = session.client("lambda")
        self.iam_client = session.client("iam")
        self.sts_client = session.client("sts")
        self.apigateway_client = session.client("apigateway")
        self.region = region

        # Verify credentials work
        try:
            identity = self.sts_client.get_caller_identity()
            self.account_id = identity["Account"]
            print(f"✓ Authenticated as: {identity.get('Arn', 'Unknown')}")
            print(f"✓ AWS Account: {self.account_id}")
        except Exception as e:
            raise Exception(f"Failed to authenticate with AWS: {e}")

    def _prefix_to_pascal_case(self, prefix: str) -> str:
        """
        Convert rs_lambda_prefix to PascalCase for IAM role naming
        Special handling for 'at' to preserve as 'AT' (acronym)
        Examples:
          carto-at- -> CartoAT
          dev-carto-at- -> DevCartoAT
          my-company- -> MyCompany
        """
        # Remove trailing hyphen/underscore
        prefix = prefix.rstrip("-_")
        # Split by hyphens or underscores
        parts = re.split(r"[-_]", prefix)
        # Capitalize each part, with special handling for 'at'
        pascal_parts = []
        for word in parts:
            if word:
                # Special case: 'at' becomes 'AT' (acronym for Analytics Toolbox)
                if word.lower() == "at":
                    pascal_parts.append("AT")
                else:
                    pascal_parts.append(word.capitalize())
        return "".join(pascal_parts)

    def _add_shared_libraries_to_zip(
        self, zf: zipfile.ZipFile, function_root: Path, handler_dir: Path
    ) -> None:
        """
        Add shared libraries to deployment package.

        Reads function.yaml to find shared_libs configuration and copies
        shared libraries from _shared/python/ into lib/ in the zip.

        Args:
            zf: ZipFile object to add files to
            function_root: Root directory of the function
            handler_dir: Directory containing the handler
        """
        import yaml

        # Load function.yaml
        yaml_path = function_root / "function.yaml"
        if not yaml_path.exists():
            return

        try:
            with open(yaml_path, "r") as f:
                config = yaml.safe_load(f)
        except Exception:
            return  # If we can't read the yaml, skip shared libs

        # Get shared_libs for redshift cloud
        cloud_config = config.get("clouds", {}).get("redshift", {})
        shared_libs = cloud_config.get("shared_libs", [])

        if not shared_libs:
            return

        # Find gateway root and shared libraries path
        gateway_root = function_root.parent.parent.parent
        shared_root = gateway_root / "functions" / "_shared" / "python"

        if not shared_root.exists():
            print(f"  Warning: Shared libraries directory not found: {shared_root}")
            return

        # Copy each shared library
        for lib_name in shared_libs:
            lib_src = shared_root / lib_name
            if not lib_src.exists():
                print(f"  Warning: Shared library not found: {lib_name}")
                continue

            if lib_src.is_dir():
                # Copy entire directory to lib/<lib_name>/
                for py_file in lib_src.rglob("*.py"):
                    if "__pycache__" in str(py_file):
                        continue
                    # Create arcname as lib/<lib_name>/<relative_path>
                    rel_path = py_file.relative_to(lib_src)
                    arcname = Path("lib") / lib_name / rel_path
                    zf.write(py_file, str(arcname))
                print(f"  ✓ Added shared library: {lib_name}/")
            elif lib_src.is_file():
                # Copy single file to lib/<filename>
                arcname = Path("lib") / lib_src.name
                zf.write(lib_src, str(arcname))
                print(f"  ✓ Added shared library: {lib_src.name}")

    def create_deployment_package(
        self,
        handler_file: Path,
        requirements_file: Optional[Path] = None,
        output_zip: Optional[Path] = None,
        include_runtime_lib: bool = True,
        function_root: Optional[Path] = None,
    ) -> Path:
        """
        Create a Lambda deployment package (zip file)

        Args:
            handler_file: Path to the handler Python file
            requirements_file: Optional requirements.txt file
            output_zip: Optional output path (creates temp file if None)
            include_runtime_lib: Include core runtime library
            function_root: Root directory of function (for finding function.yaml)

        Returns:
            Path to created zip file
        """
        if output_zip is None:
            output_zip = Path(tempfile.mktemp(suffix=".zip"))

        with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED) as zf:
            # Add handler file
            zf.write(handler_file, handler_file.name)

            # Add any lib/ directory next to the handler (for modular code)
            handler_dir = handler_file.parent
            lib_dir = handler_dir / "lib"
            if lib_dir.exists() and lib_dir.is_dir():
                for py_file in lib_dir.rglob("*.py"):
                    # Preserve the lib/ directory structure in the zip
                    arcname = py_file.relative_to(handler_dir)
                    zf.write(py_file, arcname)

            # Copy shared libraries if specified in function.yaml
            if function_root:
                self._add_shared_libraries_to_zip(zf, function_root, handler_dir)

            # Add runtime library if requested
            if include_runtime_lib:
                runtime_lib_path = Path(__file__).parent.parent / "runtime"
                if runtime_lib_path.exists():
                    for py_file in runtime_lib_path.glob("*.py"):
                        if not py_file.name.startswith("_"):
                            zf.write(py_file, f"carto/{py_file.name}")
                    # Add __init__.py for package
                    init_file = runtime_lib_path / "__init__.py"
                    if init_file.exists():
                        zf.write(init_file, "carto/__init__.py")

            # Install and add dependencies if requirements.txt exists
            if requirements_file and requirements_file.exists():
                with tempfile.TemporaryDirectory() as temp_dir:
                    temp_path = Path(temp_dir)

                    print(f"\nInstalling dependencies from {requirements_file}...")
                    # Install dependencies using pip with Lambda-compatible flags
                    # --platform: Target Linux x86_64 architecture
                    # --only-binary: Use pre-built wheels only
                    # --python-version: Match Lambda runtime version
                    result = subprocess.run(
                        [
                            sys.executable,
                            "-m",
                            "pip",
                            "install",
                            "-r",
                            str(requirements_file),
                            "-t",
                            str(temp_path),
                            "--platform",
                            "manylinux2014_x86_64",
                            "--only-binary=:all:",
                            "--python-version",
                            "3.10",
                            "--quiet",
                            "--no-compile",
                            "--upgrade",
                        ],
                        capture_output=True,
                        text=True,
                    )

                    if result.returncode != 0:
                        print(f"Warning: pip install had errors: {result.stderr}")

                    # Add all installed packages to zip
                    for item in temp_path.rglob("*"):
                        if item.is_file():
                            # Skip unnecessary files
                            if any(
                                skip in str(item)
                                for skip in [
                                    "__pycache__",
                                    ".pyc",
                                    ".pyo",
                                    ".dist-info",
                                    ".egg-info",
                                    "tests/",
                                    "test/",
                                    "docs/",
                                    "examples/",
                                ]
                            ):
                                continue
                            arcname = item.relative_to(temp_path)
                            zf.write(item, arcname)

        file_size = output_zip.stat().st_size
        size_mb = file_size / 1024 / 1024
        print(f"  ✓ Package: {output_zip.name} ({size_mb:.2f} MB)")
        return output_zip

    def get_function_code_hash(self, zip_path: Path) -> str:
        """
        Calculate SHA256 hash of deployment package

        Args:
            zip_path: Path to zip file

        Returns:
            Hex-encoded SHA256 hash
        """
        sha256 = hashlib.sha256()
        with open(zip_path, "rb") as f:
            for chunk in iter(lambda: f.read(8192), b""):
                sha256.update(chunk)
        return sha256.hexdigest()

    def function_exists(self, function_name: str) -> bool:
        """
        Check if Lambda function exists

        Args:
            function_name: Name of the function

        Returns:
            True if function exists
        """
        try:
            self.lambda_client.get_function(FunctionName=function_name)
            return True
        except self.lambda_client.exceptions.ResourceNotFoundException:
            return False
        except Exception as e:
            # If we don't have GetFunction permission, assume function doesn't exist
            # and let CreateFunction fail with a better error if it does exist
            if "AccessDenied" in str(e) or "not authorized" in str(e):
                print(
                    "Warning: Cannot check if function exists "
                    "(no GetFunction permission). Will attempt to create..."
                )
                return False
            raise

    def ensure_execution_role(self, role_name: str) -> str:
        """
        Ensure Lambda execution role exists

        Args:
            role_name: Name of the IAM role

        Returns:
            Role ARN
        """
        try:
            response = self.iam_client.get_role(RoleName=role_name)
            return response["Role"]["Arn"]
        except self.iam_client.exceptions.NoSuchEntityException:
            print(f"Creating Lambda execution role: {role_name}")

            # Create role with trust policy
            trust_policy = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {"Service": "lambda.amazonaws.com"},
                        "Action": "sts:AssumeRole",
                    }
                ],
            }

            response = self.iam_client.create_role(
                RoleName=role_name,
                AssumeRolePolicyDocument=str(trust_policy),
                Description=(
                    "Execution role for CARTO Analytics Toolbox Lambda functions"
                ),
            )

            role_arn = response["Role"]["Arn"]

            # Attach basic execution policy
            policy_arn = (
                "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
            )
            self.iam_client.attach_role_policy(RoleName=role_name, PolicyArn=policy_arn)

            # Wait for role to be available
            print("Waiting for IAM role to propagate...")
            time.sleep(10)

            return role_arn

    def create_function(
        self,
        function_name: str,
        zip_path: Path,
        handler: str,
        runtime: str = "python3.11",
        role_arn: Optional[str] = None,
        memory_size: int = 512,
        timeout: int = 60,
        environment_variables: Optional[Dict[str, str]] = None,
        description: str = "",
        layers: Optional[List[str]] = None,
    ) -> Dict[str, Any]:
        """
        Create a new Lambda function

        Args:
            function_name: Name for the Lambda function
            zip_path: Path to deployment package
            handler: Handler string (e.g., 'handler.lambda_handler')
            runtime: Python runtime version
            role_arn: IAM role ARN for Lambda execution (creates if None)
            memory_size: Memory in MB
            timeout: Timeout in seconds
            environment_variables: Environment variables
            description: Function description
            layers: Lambda layer ARNs

        Returns:
            CreateFunction response
        """
        # Ensure execution role exists
        if not role_arn:
            # Convert rs_lambda_prefix to PascalCase for IAM role (AWS convention)
            # Examples: carto-at- -> CartoATLambdaExecutionRole
            #           dev-carto-at- -> DevCartoATLambdaExecutionRole
            prefix_pascal = self._prefix_to_pascal_case(self.rs_lambda_prefix)
            role_name = f"{prefix_pascal}LambdaExecutionRole"

            # AWS IAM role names have a 64 character limit
            if len(role_name) > 64:
                raise ValueError(
                    f"IAM role name too long: '{role_name}' "
                    f"({len(role_name)} chars). "
                    f"AWS IAM role names must be ≤ 64 characters. "
                    f"Please use a shorter RS_LAMBDA_PREFIX "
                    f"(current: '{self.rs_lambda_prefix}')"
                )

            role_arn = self.ensure_execution_role(role_name)

        with open(zip_path, "rb") as f:
            zip_content = f.read()

        params = {
            "FunctionName": function_name,
            "Runtime": runtime,
            "Role": role_arn,
            "Handler": handler,
            "Code": {"ZipFile": zip_content},
            "Description": description or "CARTO Analytics Toolbox function",
            "Timeout": timeout,
            "MemorySize": memory_size,
            "Publish": True,
            "PackageType": "Zip",
        }

        if environment_variables:
            params["Environment"] = {"Variables": environment_variables}

        if layers:
            params["Layers"] = layers

        return self.lambda_client.create_function(**params)

    def needs_config_update(
        self,
        function_name: str,
        memory_size: Optional[int] = None,
        timeout: Optional[int] = None,
        handler: Optional[str] = None,
        runtime: Optional[str] = None,
    ) -> bool:
        """
        Check if function configuration needs updating

        Args:
            function_name: Name of the function
            memory_size: Desired memory size
            timeout: Desired timeout
            handler: Desired handler
            runtime: Desired runtime

        Returns:
            True if any configuration differs from current
        """
        try:
            response = self.lambda_client.get_function(FunctionName=function_name)
            config = response["Configuration"]

            if memory_size is not None and config.get("MemorySize") != memory_size:
                return True
            if timeout is not None and config.get("Timeout") != timeout:
                return True
            if handler is not None and config.get("Handler") != handler:
                return True
            if runtime is not None and config.get("Runtime") != runtime:
                return True

            return False
        except Exception as e:
            # If we can't check, assume update is needed
            if "not authorized" in str(e) or "AccessDenied" in str(e):
                return True
            raise

    def wait_for_function_active(self, function_name: str, max_wait: int = 60) -> None:
        """
        Wait for Lambda function to be in Active state

        Args:
            function_name: Name of the function
            max_wait: Maximum seconds to wait
        """
        start_time = time.time()
        while time.time() - start_time < max_wait:
            try:
                response = self.lambda_client.get_function(FunctionName=function_name)
                state = response["Configuration"].get("State")
                last_update_status = response["Configuration"].get("LastUpdateStatus")

                if state == "Active" and last_update_status == "Successful":
                    return
                elif last_update_status == "Failed":
                    reason = response["Configuration"].get(
                        "LastUpdateStatusReason", "Unknown reason"
                    )
                    raise Exception(f"Function update failed: {reason}")

                time.sleep(2)
            except Exception as e:
                if "not authorized" in str(e) or "AccessDenied" in str(e):
                    # If we can't check status, just wait a fixed time
                    time.sleep(5)
                    return
                raise

        print(
            f"Warning: Function {function_name} did not reach Active state "
            f"within {max_wait}s"
        )

    def update_function_code(
        self, function_name: str, zip_path: Path, publish: bool = False
    ) -> Dict[str, Any]:
        """
        Update Lambda function code

        Args:
            function_name: Name of the function
            zip_path: Path to new deployment package
            publish: Whether to publish a new version

        Returns:
            UpdateFunctionCode response
        """
        with open(zip_path, "rb") as f:
            zip_content = f.read()

        return self.lambda_client.update_function_code(
            FunctionName=function_name, ZipFile=zip_content, Publish=publish
        )

    def update_function_configuration(
        self,
        function_name: str,
        memory_size: Optional[int] = None,
        timeout: Optional[int] = None,
        environment_variables: Optional[Dict[str, str]] = None,
        handler: Optional[str] = None,
        runtime: Optional[str] = None,
        max_retries: int = 10,
    ) -> Dict[str, Any]:
        """
        Update Lambda function configuration

        Args:
            function_name: Name of the function
            memory_size: Memory in MB
            timeout: Timeout in seconds
            environment_variables: Environment variables
            handler: Handler string
            runtime: Runtime version
            max_retries: Maximum retry attempts if function is updating

        Returns:
            UpdateFunctionConfiguration response
        """
        params = {"FunctionName": function_name}

        if memory_size is not None:
            params["MemorySize"] = memory_size
        if timeout is not None:
            params["Timeout"] = timeout
        if environment_variables is not None:
            params["Environment"] = {"Variables": environment_variables}
        if handler is not None:
            params["Handler"] = handler
        if runtime is not None:
            params["Runtime"] = runtime

        # Retry logic for ResourceConflictException
        for attempt in range(max_retries):
            try:
                return self.lambda_client.update_function_configuration(**params)
            except Exception as e:
                if "ResourceConflictException" in str(
                    e
                ) or "update is in progress" in str(e):
                    if attempt < max_retries - 1:
                        # Exponential backoff: 3s, 6s, 9s...
                        wait_time = 3 * (attempt + 1)
                        print(
                            f"Function is updating, waiting {wait_time}s "
                            "before retry..."
                        )
                        time.sleep(wait_time)
                        continue
                raise

    def deploy_function(
        self,
        function_name: str,
        handler_file: Path,
        requirements_file: Optional[Path] = None,
        handler: str = "handler.lambda_handler",
        runtime: str = "python3.11",
        memory_size: int = 512,
        timeout: int = 60,
        description: str = "",
        environment_variables: Optional[Dict[str, str]] = None,
        role_arn: Optional[str] = None,
        update_config: bool = True,
        function_root: Optional[Path] = None,
    ) -> Dict[str, Any]:
        """
        Deploy or update a Lambda function

        Args:
            function_name: Name for the Lambda function
            handler_file: Path to handler Python file
            requirements_file: Optional requirements.txt
            handler: Handler string
            runtime: Runtime version
            memory_size: Memory in MB
            timeout: Timeout in seconds
            description: Function description
            environment_variables: Environment variables
            role_arn: IAM role ARN
            update_config: Whether to update configuration on update
            function_root: Root directory of function (for shared libraries)

        Returns:
            Deployment response
        """
        # Create deployment package
        zip_path = self.create_deployment_package(
            handler_file, requirements_file, function_root=function_root
        )

        try:
            if self.function_exists(function_name):
                # Update existing function
                print(f"Updating Lambda function: {function_name}")
                response = self.update_function_code(function_name, zip_path)

                # Update configuration if requested and if it differs
                if update_config:
                    needs_update = self.needs_config_update(
                        function_name,
                        memory_size=memory_size,
                        timeout=timeout,
                        handler=handler,
                        runtime=runtime,
                    )

                    if needs_update:
                        # Wait for code update to complete before updating configuration
                        print("Waiting for code update to complete...")
                        self.wait_for_function_active(function_name)
                        config_response = self.update_function_configuration(
                            function_name,
                            memory_size=memory_size,
                            timeout=timeout,
                            environment_variables=environment_variables,
                            handler=handler,
                            runtime=runtime,
                        )
                        print(f"✓ Updated configuration for {function_name}")
                        return config_response
                    else:
                        print("✓ Configuration unchanged, skipping config update")
                return response
            else:
                # Create new function
                print(f"Creating Lambda function: {function_name}")
                response = self.create_function(
                    function_name,
                    zip_path,
                    handler=handler,
                    runtime=runtime,
                    role_arn=role_arn,
                    memory_size=memory_size,
                    timeout=timeout,
                    environment_variables=environment_variables,
                    description=description,
                )
                print(f"✓ Created Lambda function: {function_name}")
                return response
        finally:
            # Clean up temporary zip file
            if zip_path.exists():
                zip_path.unlink()

    def delete_function(self, function_name: str) -> None:
        """
        Delete a Lambda function

        Args:
            function_name: Name of the function to delete
        """
        try:
            self.lambda_client.delete_function(FunctionName=function_name)
            print(f"✓ Deleted Lambda function: {function_name}")
        except self.lambda_client.exceptions.ResourceNotFoundException:
            print(f"Function {function_name} not found, skipping deletion")

    def get_function_arn(self, function_name: str) -> Optional[str]:
        """
        Get the ARN of a Lambda function

        Args:
            function_name: Name of the function

        Returns:
            Function ARN or None if not found
        """
        try:
            response = self.lambda_client.get_function(FunctionName=function_name)
            return response["Configuration"]["FunctionArn"]
        except self.lambda_client.exceptions.ResourceNotFoundException:
            return None

    def list_functions(self, prefix: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        List Lambda functions

        Args:
            prefix: Optional function name prefix to filter

        Returns:
            List of function configurations
        """
        functions = []
        paginator = self.lambda_client.get_paginator("list_functions")

        for page in paginator.paginate():
            for func in page["Functions"]:
                if prefix is None or func["FunctionName"].startswith(prefix):
                    functions.append(func)

        return functions

    def add_redshift_invoke_permission(
        self,
        function_name: str,
        principal: str,
        statement_id: str = "redshift-invoke",
    ) -> bool:
        """
        Add Lambda resource policy allowing Redshift role to invoke function

        This is required for Redshift external functions to invoke Lambda.
        Works for both same-account and cross-account setups.

        Args:
            function_name: Name of the Lambda function
            principal: IAM role ARN that Redshift uses (from RS_LAMBDA_INVOKE_ROLE)
            statement_id: Unique statement ID for the permission

        Returns:
            True if permission added, False if already exists
        """
        try:
            self.lambda_client.add_permission(
                FunctionName=function_name,
                StatementId=statement_id,
                Action="lambda:InvokeFunction",
                Principal=principal,
            )
            print(f"✓ Added invoke permission for Redshift role to {function_name}")
            return True
        except self.lambda_client.exceptions.ResourceConflictException:
            # Permission already exists
            print(f"  Permission already exists for {function_name}")
            return False
        except Exception as e:
            print(f"⚠ Could not add permission to {function_name}: {e}")
            return False
