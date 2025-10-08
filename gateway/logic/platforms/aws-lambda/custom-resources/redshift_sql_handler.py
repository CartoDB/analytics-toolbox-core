"""
Custom CloudFormation resource handler for executing SQL in Redshift
Allows CDK to create external functions in Redshift automatically
"""

import json
import logging
import boto3
import time
from typing import Dict, Any, Optional

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
redshift_data = boto3.client("redshift-data")


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    CloudFormation custom resource handler for Redshift SQL execution

    Event properties:
        - ClusterIdentifier: Redshift cluster identifier
        - Database: Database name
        - DbUser: Database user (for IAM auth) or None for secret auth
        - SecretArn: ARN of Secrets Manager secret (alternative to DbUser)
        - Sql: SQL statement to execute
        - Schema: Schema name (optional, for cleanup)
        - FunctionName: Function name (optional, for cleanup)

    Returns CloudFormation response
    """
    try:
        logger.info(f"Received event: {json.dumps(event)}")

        request_type = event["RequestType"]
        resource_properties = event["ResourceProperties"]

        # Extract properties
        cluster_id = resource_properties["ClusterIdentifier"]
        database = resource_properties["Database"]
        sql = resource_properties.get("Sql", "")
        db_user = resource_properties.get("DbUser")
        secret_arn = resource_properties.get("SecretArn")

        # Physical resource ID
        physical_id = event.get(
            "PhysicalResourceId",
            f"RedshiftSQL-{cluster_id}-{event['LogicalResourceId']}",
        )

        if request_type == "Create":
            logger.info("CREATE: Executing SQL in Redshift")
            execute_sql(cluster_id, database, sql, db_user, secret_arn)
            return send_response(event, "SUCCESS", physical_id, {"Status": "Created"})

        elif request_type == "Update":
            logger.info("UPDATE: Re-executing SQL in Redshift")
            # For external functions, we use CREATE OR REPLACE
            # So we can just re-execute the SQL
            execute_sql(cluster_id, database, sql, db_user, secret_arn)
            return send_response(event, "SUCCESS", physical_id, {"Status": "Updated"})

        elif request_type == "Delete":
            logger.info("DELETE: Dropping external function from Redshift")
            # Extract schema and function name for cleanup
            schema = resource_properties.get("Schema", "public")
            function_name = resource_properties.get("FunctionName")

            if function_name:
                # Generate DROP statement
                drop_sql = f"DROP FUNCTION IF EXISTS {schema}.{function_name} CASCADE;"
                logger.info(f"Executing cleanup: {drop_sql}")
                execute_sql(cluster_id, database, drop_sql, db_user, secret_arn)
            else:
                logger.warning("No FunctionName provided, skipping cleanup")

            return send_response(event, "SUCCESS", physical_id, {"Status": "Deleted"})

        else:
            logger.error(f"Unknown request type: {request_type}")
            return send_response(
                event, "FAILED", physical_id, error=f"Unknown request: {request_type}"
            )

    except Exception as e:
        logger.error(f"Error handling custom resource: {e}", exc_info=True)
        return send_response(
            event,
            "FAILED",
            event.get("PhysicalResourceId", "UNKNOWN"),
            error=str(e),
        )


def execute_sql(
    cluster_id: str,
    database: str,
    sql: str,
    db_user: Optional[str] = None,
    secret_arn: Optional[str] = None,
) -> str:
    """
    Execute SQL statement in Redshift using Data API

    Args:
        cluster_id: Redshift cluster identifier
        database: Database name
        sql: SQL statement to execute
        db_user: Database user for IAM auth (optional)
        secret_arn: Secret ARN for password auth (optional)

    Returns:
        Statement ID
    """
    logger.info(f"Executing SQL: {sql[:100]}...")

    # Prepare execute_statement params
    params = {
        "ClusterIdentifier": cluster_id,
        "Database": database,
        "Sql": sql,
    }

    # Use either IAM auth or secret auth
    if db_user:
        params["DbUser"] = db_user
    elif secret_arn:
        params["SecretArn"] = secret_arn
    else:
        raise ValueError("Either DbUser or SecretArn must be provided")

    # Execute statement
    response = redshift_data.execute_statement(**params)
    statement_id = response["Id"]

    logger.info(f"Statement submitted: {statement_id}")

    # Wait for completion
    wait_for_completion(statement_id)

    return statement_id


def wait_for_completion(statement_id: str, max_wait: int = 300) -> None:
    """
    Wait for SQL statement to complete

    Args:
        statement_id: Statement ID to wait for
        max_wait: Maximum time to wait in seconds
    """
    start_time = time.time()

    while True:
        if time.time() - start_time > max_wait:
            raise TimeoutError(
                f"SQL execution timed out after {max_wait} seconds: {statement_id}"
            )

        response = redshift_data.describe_statement(Id=statement_id)
        status = response["Status"]

        logger.info(f"Statement {statement_id} status: {status}")

        if status == "FINISHED":
            logger.info("SQL execution completed successfully")
            return

        elif status == "FAILED":
            error = response.get("Error", "Unknown error")
            raise RuntimeError(f"SQL execution failed: {error}")

        elif status == "ABORTED":
            raise RuntimeError("SQL execution was aborted")

        # Still running, wait and check again
        time.sleep(2)


def send_response(
    event: Dict[str, Any],
    status: str,
    physical_id: str,
    data: Optional[Dict[str, Any]] = None,
    error: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Send response back to CloudFormation

    Args:
        event: Original CloudFormation event
        status: SUCCESS or FAILED
        physical_id: Physical resource ID
        data: Response data
        error: Error reason (if FAILED)

    Returns:
        Response dict
    """
    response = {
        "Status": status,
        "PhysicalResourceId": physical_id,
        "StackId": event["StackId"],
        "RequestId": event["RequestId"],
        "LogicalResourceId": event["LogicalResourceId"],
    }

    if data:
        response["Data"] = data

    if error:
        response["Reason"] = error

    logger.info(f"Sending response: {json.dumps(response)}")

    # In a real implementation, we would send this to the ResponseURL
    # For now, we'll just return it
    # import urllib3
    # http = urllib3.PoolManager()
    # http.request('PUT', event['ResponseURL'], body=json.dumps(response))

    return response
