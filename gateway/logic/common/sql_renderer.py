"""
SQL template renderer for external functions
Renders Jinja2 templates with function metadata
"""

from pathlib import Path
from typing import Dict, Any, Optional
from jinja2 import Environment, FileSystemLoader


class SQLRenderer:
    """Renders SQL templates for external functions"""

    def __init__(self, template_dir: Optional[Path] = None):
        """
        Initialize SQL renderer

        Args:
            template_dir: Directory containing SQL templates (optional)
        """
        self.template_dir = template_dir
        if template_dir:
            self.env = Environment(loader=FileSystemLoader(str(template_dir)))
        else:
            self.env = Environment()

    def render_from_file(self, template_path: Path, context: Dict[str, Any]) -> str:
        """
        Render SQL from a template file

        Args:
            template_path: Path to template file
            context: Template context variables

        Returns:
            Rendered SQL string
        """
        with open(template_path, "r") as f:
            template_content = f.read()

        template = self.env.from_string(template_content)
        return template.render(**context)

    def render_from_string(self, template_str: str, context: Dict[str, Any]) -> str:
        """
        Render SQL from a template string

        Args:
            template_str: Template string
            context: Template context variables

        Returns:
            Rendered SQL string
        """
        template = self.env.from_string(template_str)
        return template.render(**context)

    def render_external_function(
        self,
        template_path: Path,
        function_name: str,
        lambda_arn: str,
        iam_role_arn: str,
        schema: str = "public",
        **kwargs,
    ) -> str:
        """
        Render external function SQL

        Args:
            template_path: Path to SQL template
            function_name: Name of the function
            lambda_arn: ARN of the Lambda function
            iam_role_arn: ARN of the IAM role for Redshift
            schema: Database schema
            **kwargs: Additional template variables

        Returns:
            Rendered SQL string
        """
        context = {
            "function_name": function_name,
            "lambda_arn": lambda_arn,
            "iam_role_arn": iam_role_arn,
            "schema": schema,
            **kwargs,
        }

        return self.render_from_file(template_path, context)


def render_all_external_functions(
    functions_root: Path,
    lambda_arns: Dict[str, str],
    iam_role_arn: str,
    schema: str = "public",
) -> Dict[str, str]:
    """
    Render SQL for all external functions

    Args:
        functions_root: Root directory containing functions
        lambda_arns: Dict mapping function names to Lambda ARNs
        iam_role_arn: IAM role ARN for Redshift
        schema: Database schema

    Returns:
        Dict mapping function names to rendered SQL
    """
    renderer = SQLRenderer()
    sql_statements = {}

    # Find all SQL templates
    for sql_template in functions_root.rglob("*external*.sql.j2"):
        # Extract function name from path
        # Assuming structure: functions/{category}/{function_name}/code/{template}
        function_dir = sql_template.parent.parent
        function_name = function_dir.name

        if function_name in lambda_arns:
            sql = renderer.render_external_function(
                sql_template,
                function_name,
                lambda_arns[function_name],
                iam_role_arn,
                schema,
            )
            sql_statements[function_name] = sql

    return sql_statements
