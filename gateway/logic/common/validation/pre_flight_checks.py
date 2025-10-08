"""
Pre-flight checks for Analytics Toolbox deployment
Validates environment, credentials, and prerequisites before deployment
"""

import boto3
import subprocess
import sys
from pathlib import Path
from typing import List, Optional
from dataclasses import dataclass
from enum import Enum


class CheckStatus(Enum):
    """Status of a pre-flight check"""

    PASS = "✓"
    FAIL = "✗"
    WARNING = "⚠"
    SKIP = "○"


@dataclass
class CheckResult:
    """Result of a pre-flight check"""

    name: str
    status: CheckStatus
    message: str
    details: Optional[str] = None
    error: Optional[Exception] = None


class PreFlightChecker:
    """Performs pre-flight checks before deployment"""

    def __init__(self, verbose: bool = False):
        """
        Initialize pre-flight checker

        Args:
            verbose: Show detailed information
        """
        self.verbose = verbose
        self.results: List[CheckResult] = []

    def run_all_checks(
        self,
        aws_profile: Optional[str] = None,
        region: str = "us-east-1",
        cluster_id: Optional[str] = None,
        database: Optional[str] = None,
    ) -> bool:
        """
        Run all pre-flight checks

        Args:
            aws_profile: AWS profile name
            region: AWS region
            cluster_id: Redshift cluster identifier (optional)
            database: Database name (optional)

        Returns:
            True if all critical checks pass
        """
        print("\n" + "=" * 70)
        print("CARTO Analytics Toolbox - Pre-Flight Checks")
        print("=" * 70 + "\n")

        # Environment checks
        self._check_python_version()
        self._check_aws_cli()
        self._check_cdk_cli()
        self._check_node_version()

        # AWS checks
        self._check_aws_credentials(aws_profile)
        self._check_aws_region(region, aws_profile)

        # Package checks
        self._check_package_structure()
        self._check_lambda_code()

        # Optional infrastructure checks
        if cluster_id:
            self._check_redshift_cluster(cluster_id, region, aws_profile)

        if cluster_id and database:
            self._check_redshift_connectivity(cluster_id, database, region, aws_profile)

        # Display results
        self._display_results()

        # Return overall status
        return self._get_overall_status()

    def _check_python_version(self):
        """Check Python version"""
        try:
            version = sys.version_info
            version_str = f"{version.major}.{version.minor}.{version.micro}"

            if version.major == 3 and version.minor >= 8:
                self.results.append(
                    CheckResult(
                        name="Python Version",
                        status=CheckStatus.PASS,
                        message=f"Python {version_str}",
                    )
                )
            else:
                self.results.append(
                    CheckResult(
                        name="Python Version",
                        status=CheckStatus.FAIL,
                        message=f"Python {version_str} - requires Python 3.8+",
                    )
                )
        except Exception as e:
            self.results.append(
                CheckResult(
                    name="Python Version",
                    status=CheckStatus.FAIL,
                    message="Could not determine Python version",
                    error=e,
                )
            )

    def _check_aws_cli(self):
        """Check AWS CLI installation"""
        try:
            result = subprocess.run(
                ["aws", "--version"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            version = result.stdout.split()[0] if result.stdout else "unknown"

            if result.returncode == 0:
                self.results.append(
                    CheckResult(
                        name="AWS CLI",
                        status=CheckStatus.PASS,
                        message=f"Installed ({version})",
                    )
                )
            else:
                self.results.append(
                    CheckResult(
                        name="AWS CLI",
                        status=CheckStatus.FAIL,
                        message="Not working properly",
                        details=result.stderr,
                    )
                )
        except FileNotFoundError:
            self.results.append(
                CheckResult(
                    name="AWS CLI",
                    status=CheckStatus.FAIL,
                    message="Not installed",
                    details="Install from: https://aws.amazon.com/cli/",
                )
            )
        except Exception as e:
            self.results.append(
                CheckResult(
                    name="AWS CLI",
                    status=CheckStatus.FAIL,
                    message="Check failed",
                    error=e,
                )
            )

    def _check_cdk_cli(self):
        """Check AWS CDK CLI installation"""
        try:
            result = subprocess.run(
                ["cdk", "--version"],
                capture_output=True,
                text=True,
                timeout=5,
            )

            if result.returncode == 0:
                version = result.stdout.strip()
                self.results.append(
                    CheckResult(
                        name="AWS CDK",
                        status=CheckStatus.PASS,
                        message=f"Installed ({version})",
                    )
                )
            else:
                self.results.append(
                    CheckResult(
                        name="AWS CDK",
                        status=CheckStatus.WARNING,
                        message="Not installed (optional)",
                        details="Install: npm install -g aws-cdk",
                    )
                )
        except FileNotFoundError:
            self.results.append(
                CheckResult(
                    name="AWS CDK",
                    status=CheckStatus.WARNING,
                    message="Not installed (optional)",
                    details="Install: npm install -g aws-cdk",
                )
            )
        except Exception as e:
            self.results.append(
                CheckResult(
                    name="AWS CDK",
                    status=CheckStatus.WARNING,
                    message="Check failed",
                    error=e,
                )
            )

    def _check_node_version(self):
        """Check Node.js version (required for CDK)"""
        try:
            result = subprocess.run(
                ["node", "--version"],
                capture_output=True,
                text=True,
                timeout=5,
            )

            if result.returncode == 0:
                version = result.stdout.strip()
                # Extract major version
                major_version = int(version.lstrip("v").split(".")[0])

                if major_version >= 14:
                    self.results.append(
                        CheckResult(
                            name="Node.js",
                            status=CheckStatus.PASS,
                            message=f"Installed ({version})",
                        )
                    )
                else:
                    self.results.append(
                        CheckResult(
                            name="Node.js",
                            status=CheckStatus.WARNING,
                            message=f"{version} - CDK requires Node.js 14+",
                        )
                    )
            else:
                self.results.append(
                    CheckResult(
                        name="Node.js",
                        status=CheckStatus.WARNING,
                        message="Not working properly",
                    )
                )
        except FileNotFoundError:
            self.results.append(
                CheckResult(
                    name="Node.js",
                    status=CheckStatus.WARNING,
                    message="Not installed (required for CDK)",
                    details="Install from: https://nodejs.org/",
                )
            )
        except Exception as e:
            self.results.append(
                CheckResult(
                    name="Node.js",
                    status=CheckStatus.WARNING,
                    message="Check failed",
                    error=e,
                )
            )

    def _check_aws_credentials(self, profile: Optional[str] = None):
        """Check AWS credentials are configured"""
        try:
            session = boto3.Session(profile_name=profile)
            sts = session.client("sts")

            identity = sts.get_caller_identity()
            account_id = identity["Account"]
            arn = identity["Arn"]

            # Extract user/role name from ARN
            identity_name = arn.split("/")[-1]

            self.results.append(
                CheckResult(
                    name="AWS Credentials",
                    status=CheckStatus.PASS,
                    message=f"Configured (Account: {account_id})",
                    details=f"Identity: {identity_name}",
                )
            )
        except Exception as e:
            self.results.append(
                CheckResult(
                    name="AWS Credentials",
                    status=CheckStatus.FAIL,
                    message="Not configured or invalid",
                    details="Run: aws configure",
                    error=e,
                )
            )

    def _check_aws_region(self, region: str, profile: Optional[str] = None):
        """Check AWS region is valid and accessible"""
        try:
            session = boto3.Session(profile_name=profile, region_name=region)
            ec2 = session.client("ec2")

            # Try to describe regions to verify access
            response = ec2.describe_regions(RegionNames=[region])

            if response["Regions"]:
                self.results.append(
                    CheckResult(
                        name="AWS Region",
                        status=CheckStatus.PASS,
                        message=f"{region} is accessible",
                    )
                )
            else:
                self.results.append(
                    CheckResult(
                        name="AWS Region",
                        status=CheckStatus.FAIL,
                        message=f"{region} not found",
                    )
                )
        except Exception as e:
            self.results.append(
                CheckResult(
                    name="AWS Region",
                    status=CheckStatus.FAIL,
                    message=f"Cannot access region {region}",
                    error=e,
                )
            )

    def _check_package_structure(self):
        """Check package directory structure"""
        required_dirs = ["cdk", "lambdas", "sql", "scripts"]
        current_dir = Path.cwd()

        missing_dirs = []
        for dir_name in required_dirs:
            if not (current_dir / dir_name).exists():
                missing_dirs.append(dir_name)

        if not missing_dirs:
            self.results.append(
                CheckResult(
                    name="Package Structure",
                    status=CheckStatus.PASS,
                    message="All required directories present",
                )
            )
        else:
            self.results.append(
                CheckResult(
                    name="Package Structure",
                    status=CheckStatus.FAIL,
                    message=f"Missing directories: {', '.join(missing_dirs)}",
                    details="Run this from the package root directory",
                )
            )

    def _check_lambda_code(self):
        """Check Lambda function code exists"""
        lambdas_dir = Path.cwd() / "lambdas"

        if not lambdas_dir.exists():
            self.results.append(
                CheckResult(
                    name="Lambda Functions",
                    status=CheckStatus.SKIP,
                    message="lambdas/ directory not found",
                )
            )
            return

        lambda_functions = [d for d in lambdas_dir.iterdir() if d.is_dir()]

        if not lambda_functions:
            self.results.append(
                CheckResult(
                    name="Lambda Functions",
                    status=CheckStatus.WARNING,
                    message="No Lambda functions found",
                )
            )
            return

        # Check each function has handler
        invalid_functions = []
        for func_dir in lambda_functions:
            handler_file = func_dir / "handler.py"
            index_file = func_dir / "index.py"

            if not handler_file.exists() and not index_file.exists():
                invalid_functions.append(func_dir.name)

        if not invalid_functions:
            self.results.append(
                CheckResult(
                    name="Lambda Functions",
                    status=CheckStatus.PASS,
                    message=f"Found {len(lambda_functions)} function(s)",
                    details=", ".join(f.name for f in lambda_functions),
                )
            )
        else:
            self.results.append(
                CheckResult(
                    name="Lambda Functions",
                    status=CheckStatus.WARNING,
                    message=f"Missing handlers: {', '.join(invalid_functions)}",
                )
            )

    def _check_redshift_cluster(
        self, cluster_id: str, region: str, profile: Optional[str] = None
    ):
        """Check Redshift cluster exists and is available"""
        try:
            session = boto3.Session(profile_name=profile, region_name=region)
            redshift = session.client("redshift")

            response = redshift.describe_clusters(ClusterIdentifier=cluster_id)
            clusters = response.get("Clusters", [])

            if not clusters:
                self.results.append(
                    CheckResult(
                        name="Redshift Cluster",
                        status=CheckStatus.FAIL,
                        message=f"Cluster '{cluster_id}' not found",
                    )
                )
                return

            cluster = clusters[0]
            status = cluster["ClusterStatus"]
            endpoint = cluster.get("Endpoint", {})

            if status == "available":
                self.results.append(
                    CheckResult(
                        name="Redshift Cluster",
                        status=CheckStatus.PASS,
                        message=f"Cluster '{cluster_id}' is available",
                        details=f"Endpoint: {endpoint.get('Address', 'N/A')}",
                    )
                )
            else:
                self.results.append(
                    CheckResult(
                        name="Redshift Cluster",
                        status=CheckStatus.WARNING,
                        message=f"Cluster '{cluster_id}' status: {status}",
                        details="Cluster must be 'available' for deployment",
                    )
                )

        except Exception as e:
            self.results.append(
                CheckResult(
                    name="Redshift Cluster",
                    status=CheckStatus.FAIL,
                    message=f"Cannot access cluster '{cluster_id}'",
                    error=e,
                )
            )

    def _check_redshift_connectivity(
        self,
        cluster_id: str,
        database: str,
        region: str,
        profile: Optional[str] = None,
    ):
        """Check Redshift Data API connectivity"""
        try:
            session = boto3.Session(profile_name=profile, region_name=region)
            redshift_data = session.client("redshift-data")

            # Try a simple query
            response = redshift_data.execute_statement(
                ClusterIdentifier=cluster_id,
                Database=database,
                Sql="SELECT 1",
            )

            statement_id = response["Id"]

            # Wait briefly for result
            import time

            for _ in range(5):
                status_response = redshift_data.describe_statement(Id=statement_id)
                status = status_response["Status"]

                if status == "FINISHED":
                    self.results.append(
                        CheckResult(
                            name="Redshift Connectivity",
                            status=CheckStatus.PASS,
                            message=f"Successfully connected to '{database}'",
                        )
                    )
                    return
                elif status in ["FAILED", "ABORTED"]:
                    error = status_response.get("Error", "Unknown error")
                    self.results.append(
                        CheckResult(
                            name="Redshift Connectivity",
                            status=CheckStatus.FAIL,
                            message=f"Connection test failed: {error}",
                        )
                    )
                    return

                time.sleep(1)

            self.results.append(
                CheckResult(
                    name="Redshift Connectivity",
                    status=CheckStatus.WARNING,
                    message="Connection test timed out",
                    details="Data API may be slow or inaccessible",
                )
            )

        except Exception as e:
            self.results.append(
                CheckResult(
                    name="Redshift Connectivity",
                    status=CheckStatus.FAIL,
                    message="Cannot connect to Redshift",
                    error=e,
                )
            )

    def _display_results(self):
        """Display all check results"""
        print("\nResults:")
        print("-" * 70)

        for result in self.results:
            status_icon = result.status.value
            print(f"{status_icon} {result.name:.<30} {result.message}")

            if self.verbose and result.details:
                print(f"    {result.details}")

            if self.verbose and result.error:
                print(f"    Error: {str(result.error)}")

        print("-" * 70)

    def _get_overall_status(self) -> bool:
        """
        Determine overall status

        Returns:
            True if no critical failures
        """
        failures = [r for r in self.results if r.status == CheckStatus.FAIL]
        warnings = [r for r in self.results if r.status == CheckStatus.WARNING]

        if failures:
            print(f"\n❌ {len(failures)} critical check(s) failed")
            print("Please resolve the issues above before deploying.\n")
            return False

        if warnings:
            print(f"\n⚠️  {len(warnings)} warning(s) found")
            print("Deployment may proceed but some features may be limited.\n")

        print("✅ All critical checks passed!\n")
        return True


def run_pre_flight_checks(
    aws_profile: Optional[str] = None,
    region: str = "us-east-1",
    cluster_id: Optional[str] = None,
    database: Optional[str] = None,
    verbose: bool = False,
) -> bool:
    """
    Run pre-flight checks

    Args:
        aws_profile: AWS profile name
        region: AWS region
        cluster_id: Redshift cluster identifier
        database: Database name
        verbose: Show detailed information

    Returns:
        True if checks pass
    """
    checker = PreFlightChecker(verbose=verbose)
    return checker.run_all_checks(aws_profile, region, cluster_id, database)
