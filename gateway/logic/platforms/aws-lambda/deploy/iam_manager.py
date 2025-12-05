"""
IAM role management for Redshift Lambda invocation
Handles creation and attachment of roles for external functions
"""

import boto3
import json
import time
from typing import Optional
from botocore.exceptions import ClientError


class IAMRoleManager:
    """Manages IAM roles for Redshift to invoke Lambda functions"""

    def __init__(
        self,
        region: str = "us-east-1",
        session: Optional[boto3.Session] = None,
    ):
        """
        Initialize IAM role manager

        Args:
            region: AWS region
            session: Optional boto3 session (uses default credentials if not provided)
        """
        if session:
            self.iam_client = session.client("iam")
            self.redshift_client = session.client("redshift", region_name=region)
        else:
            self.iam_client = boto3.client("iam")
            self.redshift_client = boto3.client("redshift", region_name=region)

        self.region = region

    def get_or_create_redshift_invoke_role(
        self,
        role_name: str,
        lambda_account_id: str,
        redshift_account_id: Optional[str] = None,
    ) -> str:
        """
        Get or create IAM role for Redshift to invoke Lambda functions

        This role is attached to the Redshift cluster and referenced in
        CREATE EXTERNAL FUNCTION ... IAM_ROLE 'arn:...'

        Args:
            role_name: Name for the IAM role
            lambda_account_id: AWS account where Lambdas are deployed
            redshift_account_id: AWS account where Redshift lives (None = same account)

        Returns:
            Role ARN
        """
        try:
            response = self.iam_client.get_role(RoleName=role_name)
            print(f"✓ Using existing Redshift invoke role: {role_name}")
            return response["Role"]["Arn"]
        except self.iam_client.exceptions.NoSuchEntityException:
            print(f"Creating Redshift invoke role: {role_name}")

            # Determine if cross-account setup
            is_cross_account = (
                redshift_account_id and redshift_account_id != lambda_account_id
            )

            # Create trust policy
            if is_cross_account:
                # Cross-account: Trust Redshift service in remote account
                trust_policy = {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {"Service": "redshift.amazonaws.com"},
                            "Action": "sts:AssumeRole",
                            "Condition": {
                                "StringEquals": {
                                    "sts:ExternalId": f"redshift-{redshift_account_id}"
                                }
                            },
                        }
                    ],
                }
            else:
                # Same-account: Simple trust policy
                trust_policy = {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {"Service": "redshift.amazonaws.com"},
                            "Action": "sts:AssumeRole",
                        }
                    ],
                }

            # Create role
            response = self.iam_client.create_role(
                RoleName=role_name,
                AssumeRolePolicyDocument=json.dumps(trust_policy),
                Description=(
                    "Role for Redshift cluster to invoke CARTO Analytics Toolbox "
                    "Lambda functions"
                ),
            )

            role_arn = response["Role"]["Arn"]

            # Create inline policy for Lambda invocation
            policy_document = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": "lambda:InvokeFunction",
                        "Resource": (
                            f"arn:aws:lambda:{self.region}"
                            f":{lambda_account_id}:function:*"
                        ),
                    }
                ],
            }

            self.iam_client.put_role_policy(
                RoleName=role_name,
                PolicyName="RedshiftLambdaInvokePolicy",
                PolicyDocument=json.dumps(policy_document),
            )

            print(f"✓ Created Redshift invoke role: {role_arn}")
            print("  Waiting for IAM propagation...")
            time.sleep(10)  # Wait for IAM propagation

            return role_arn

    def attach_role_to_cluster(self, cluster_identifier: str, role_arn: str) -> bool:
        """
        Attach IAM role to Redshift cluster

        Args:
            cluster_identifier: Redshift cluster ID
            role_arn: IAM role ARN to attach

        Returns:
            True if attached successfully, False if already attached or failed
        """
        try:
            # Get current attached roles
            response = self.redshift_client.describe_clusters(
                ClusterIdentifier=cluster_identifier
            )
            cluster = response["Clusters"][0]
            current_roles = [r["IamRoleArn"] for r in cluster.get("IamRoles", [])]

            if role_arn in current_roles:
                print(f"✓ Role already attached to cluster {cluster_identifier}")
                return False

            # Attach new role
            self.redshift_client.modify_cluster_iam_roles(
                ClusterIdentifier=cluster_identifier, AddIamRoles=[role_arn]
            )

            print(f"✓ Attached role to Redshift cluster {cluster_identifier}")
            return True

        except ClientError as e:
            error_code = e.response.get("Error", {}).get("Code", "")
            error_msg = e.response.get("Error", {}).get("Message", str(e))

            if error_code == "ClusterNotFound":
                print(
                    "⚠ Cluster '{}' not found in this account/region".format(
                        cluster_identifier
                    )
                )
            elif error_code == "AccessDenied":
                print(
                    "⚠ Insufficient permissions to attach role to cluster "
                    "(need redshift:ModifyClusterIamRoles)"
                )
            else:
                print("⚠ Could not auto-attach role to cluster: {}".format(error_msg))

            print(
                f"\n  Please manually attach role to your Redshift cluster:\n"
                f"  AWS Console → Redshift → Clusters → {cluster_identifier} → "
                f"Properties → Manage IAM roles → Attach:\n"
                f"  {role_arn}\n"
            )
            return False

        except Exception as e:
            print(f"⚠ Unexpected error attaching role to cluster: {e}")
            return False

    def get_account_id(self) -> str:
        """
        Get AWS account ID for current credentials

        Returns:
            AWS account ID
        """
        try:
            sts_client = boto3.client("sts")
            response = sts_client.get_caller_identity()
            return response["Account"]
        except Exception as e:
            raise RuntimeError(f"Could not determine AWS account ID: {e}")
