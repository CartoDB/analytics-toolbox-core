"""
Script to create external functions in Redshift using CDK custom resource
This runs after CDK deployment to register the Lambda functions as external functions
"""

import boto3
from pathlib import Path
from typing import Dict


def get_stack_outputs(stack_name: str, region: str = "us-east-1") -> Dict[str, str]:
    """
    Get CloudFormation stack outputs

    Args:
        stack_name: Stack name
        region: AWS region

    Returns:
        Dict of output keys to values
    """
    cfn = boto3.client("cloudformation", region_name=region)

    response = cfn.describe_stacks(StackName=stack_name)
    stacks = response.get("Stacks", [])

    if not stacks:
        raise ValueError(f"Stack not found: {stack_name}")

    outputs = {}
    for output in stacks[0].get("Outputs", []):
        outputs[output["OutputKey"]] = output["OutputValue"]

    return outputs


def render_sql_template(
    template_path: Path, lambda_arn: str, iam_role_arn: str, schema: str = "public"
) -> str:
    """
    Render SQL template with Lambda ARN and IAM role

    Args:
        template_path: Path to SQL template file
        lambda_arn: Lambda function ARN
        iam_role_arn: IAM role ARN for Redshift
        schema: Database schema

    Returns:
        Rendered SQL string
    """
    from jinja2 import Template

    with open(template_path, "r") as f:
        template = Template(f.read())

    return template.render(
        lambda_arn=lambda_arn, iam_role_arn=iam_role_arn, schema=schema
    )


def create_external_functions(
    stack_name: str,
    cluster_id: str,
    database: str,
    db_user: str,
    schema: str = "public",
    region: str = "us-east-1",
):
    """
    Create external functions in Redshift

    Args:
        stack_name: CloudFormation stack name
        cluster_id: Redshift cluster identifier
        database: Database name
        db_user: Database user
        schema: Database schema
        region: AWS region
    """
    print(f"Getting stack outputs for: {stack_name}")
    outputs = get_stack_outputs(stack_name, region)

    # Get IAM role ARN
    iam_role_arn = outputs.get("RedshiftInvokeRoleArn")
    if not iam_role_arn:
        raise ValueError("RedshiftInvokeRoleArn not found in stack outputs")

    print(f"IAM Role ARN: {iam_role_arn}")

    # Get Lambda ARNs
    lambda_arns = {}
    for key, value in outputs.items():
        if key.endswith("LambdaArn"):
            function_name = key.replace("LambdaArn", "").lower()
            lambda_arns[function_name] = value
            print(f"Found Lambda: {function_name} -> {value}")

    if not lambda_arns:
        print("Warning: No Lambda ARNs found in stack outputs")
        return

    # Find and render SQL templates
    sql_dir = Path(__file__).parent.parent.parent.parent.parent / "sql"
    if not sql_dir.exists():
        sql_dir = Path("./sql")

    redshift_data = boto3.client("redshift-data", region_name=region)

    for function_name, lambda_arn in lambda_arns.items():
        # Find SQL template
        template_pattern = f"*{function_name}*.sql.j2"
        templates = list(sql_dir.rglob(template_pattern))

        if not templates:
            print(f"Warning: No SQL template found for {function_name}")
            continue

        template_path = templates[0]
        print(f"\nProcessing {function_name}:")
        print(f"  Template: {template_path}")

        # Render SQL
        sql = render_sql_template(template_path, lambda_arn, iam_role_arn, schema)
        print(f"  SQL: {sql[:100]}...")

        # Execute SQL using Redshift Data API
        print("  Executing SQL...")
        response = redshift_data.execute_statement(
            ClusterIdentifier=cluster_id,
            Database=database,
            DbUser=db_user,
            Sql=sql,
        )

        statement_id = response["Id"]
        print(f"  Statement ID: {statement_id}")

        # Wait for completion
        import time

        for i in range(30):
            status_response = redshift_data.describe_statement(Id=statement_id)
            status = status_response["Status"]

            if status == "FINISHED":
                print("  ✓ External function created successfully")
                break
            elif status == "FAILED":
                error = status_response.get("Error", "Unknown error")
                print(f"  ✗ Failed: {error}")
                break
            elif status == "ABORTED":
                print("  ✗ Aborted")
                break

            time.sleep(2)

    print("\n✓ All external functions processed")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Create external functions in Redshift"
    )
    parser.add_argument("--stack-name", required=True, help="CloudFormation stack name")
    parser.add_argument(
        "--cluster-id", required=True, help="Redshift cluster identifier"
    )
    parser.add_argument("--database", required=True, help="Database name")
    parser.add_argument("--db-user", required=True, help="Database user")
    parser.add_argument("--schema", default="public", help="Database schema")
    parser.add_argument("--region", default="us-east-1", help="AWS region")

    args = parser.parse_args()

    create_external_functions(
        stack_name=args.stack_name,
        cluster_id=args.cluster_id,
        database=args.database,
        db_user=args.db_user,
        schema=args.schema,
        region=args.region,
    )
