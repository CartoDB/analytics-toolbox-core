"""
Simple template renderer for SQL files using @@VARIABLE@@ placeholders
Replaces Jinja2 dependency with a straightforward string replacement approach
"""

from pathlib import Path
from typing import Dict


class TemplateRenderer:
    """Simple template renderer using @@VARIABLE@@ syntax"""

    @staticmethod
    def render(template_path: Path, variables: Dict[str, str]) -> str:
        """
        Render a template file by replacing @@VARIABLE@@ placeholders

        Args:
            template_path: Path to template file
            variables: Dictionary of variable names to values

        Returns:
            Rendered template string

        Example:
            >>> renderer = TemplateRenderer()
            >>> variables = {"schema": "dev_user", "lambda_arn": "arn:aws:..."}
            >>> sql = renderer.render(Path("template.sql"), variables)
        """
        with open(template_path, "r") as f:
            template = f.read()

        # Replace @@VARIABLE@@ with actual values
        for var_name, var_value in variables.items():
            placeholder = f"@@{var_name.upper()}@@"
            template = template.replace(placeholder, var_value)

        return template

    @staticmethod
    def render_external_function(
        template_path: Path,
        function_name: str,
        lambda_arn: str,
        iam_role_arn: str,
        schema: str,
    ) -> str:
        """
        Convenience method for rendering external function templates

        Args:
            template_path: Path to SQL template file
            function_name: Name of the function
            lambda_arn: ARN of the Lambda function
            iam_role_arn: ARN of the IAM role for Redshift
            schema: Schema name (e.g., 'carto', 'dev_username')

        Returns:
            Rendered SQL string
        """
        variables = {
            "function_name": function_name,
            "lambda_arn": lambda_arn,
            "iam_role_arn": iam_role_arn,  # Maps to @@IAM_ROLE_ARN@@ in SQL templates
            "schema": schema,
        }
        return TemplateRenderer.render(template_path, variables)
