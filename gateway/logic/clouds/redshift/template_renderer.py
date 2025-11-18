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

            # Special handling for empty values: remove the entire line
            if var_value == "":
                lines = template.split("\n")
                new_lines = []
                for line in lines:
                    if placeholder not in line:
                        new_lines.append(line)
                    # Skip lines containing placeholders with empty values
                template = "\n".join(new_lines)
            else:
                template = template.replace(placeholder, var_value)

        return template

    @staticmethod
    def render_external_function(
        template_path: Path,
        function_name: str,
        lambda_arn: str,
        iam_role_arn: str,
        schema: str,
        package_version: str = "0.0.0",
        max_batch_rows: int = None,
    ) -> str:
        """
        Convenience method for rendering external function templates

        Args:
            template_path: Path to SQL template file
            function_name: Name of the function
            lambda_arn: ARN of the Lambda function
            iam_role_arn: ARN of the IAM role for Redshift
            schema: Schema name (e.g., 'carto', 'dev_username')
            package_version: Package version (e.g., '1.11.2') for @@PACKAGE_VERSION@@
            max_batch_rows: Maximum rows per batch (for @@MAX_BATCH_ROWS@@)

        Returns:
            Rendered SQL string
        """
        variables = {
            "function_name": function_name,
            "lambda_arn": lambda_arn,
            "iam_role_arn": iam_role_arn,  # Maps to @@IAM_ROLE_ARN@@ in SQL templates
            "schema": schema,
            "package_version": package_version,  # Maps to @@PACKAGE_VERSION@@
        }

        # Add MAX_BATCH_ROWS value if specified, otherwise empty string
        # SQL template has "MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@;"
        # so we just replace the value
        if max_batch_rows is not None:
            variables["max_batch_rows"] = str(max_batch_rows)
        else:
            variables["max_batch_rows"] = ""

        return TemplateRenderer.render(template_path, variables)
