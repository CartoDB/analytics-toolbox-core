"""
Validation logic for function definitions and configurations
"""

import yaml
from pathlib import Path
from typing import List, Dict, Any, Optional
import jsonschema


class ValidationError(Exception):
    """Raised when validation fails"""

    pass


class FunctionValidator:
    """Validates function.yaml files against schema and business rules"""

    def __init__(self, schema_path: Optional[Path] = None):
        """
        Initialize validator with schema

        Args:
            schema_path: Path to function.schema.json, uses default if None
        """
        self.schema_path = schema_path
        self.schema = self._load_schema() if schema_path else None

    def _load_schema(self) -> Dict[str, Any]:
        """Load JSON schema from file"""
        if not self.schema_path or not self.schema_path.exists():
            raise ValidationError(f"Schema file not found: {self.schema_path}")

        with open(self.schema_path, "r") as f:
            return yaml.safe_load(f)

    def validate_yaml_structure(self, yaml_data: Dict[str, Any]) -> None:
        """
        Validate YAML structure against JSON schema

        Args:
            yaml_data: Parsed YAML data

        Raises:
            ValidationError: If validation fails
        """
        if not self.schema:
            return

        try:
            jsonschema.validate(instance=yaml_data, schema=self.schema)
        except jsonschema.ValidationError as e:
            raise ValidationError(f"Schema validation failed: {e.message}")

    def validate_code_files_exist(
        self, function_dir: Path, yaml_data: Dict[str, Any]
    ) -> None:
        """
        Validate that all referenced code files exist

        Args:
            function_dir: Directory containing the function
            yaml_data: Parsed function.yaml data

        Raises:
            ValidationError: If code files are missing
        """
        clouds = yaml_data.get("clouds", {})

        for cloud_name, cloud_config in clouds.items():
            code_file = cloud_config.get("code_file")
            if code_file:
                code_path = function_dir / code_file
                if not code_path.exists():
                    raise ValidationError(
                        f"Code file not found for {cloud_name}: {code_path}"
                    )

            requirements_file = cloud_config.get("requirements_file")
            if requirements_file:
                req_path = function_dir / requirements_file
                if not req_path.exists():
                    raise ValidationError(
                        f"Requirements file not found for {cloud_name}: {req_path}"
                    )

            template_file = cloud_config.get("external_function_template")
            if template_file:
                template_path = function_dir / template_file
                if not template_path.exists():
                    raise ValidationError(
                        f"Template file not found for {cloud_name}: {template_path}"
                    )

    def validate_shared_libs_exist(
        self, function_dir: Path, yaml_data: Dict[str, Any]
    ) -> None:
        """
        Validate that all referenced shared libraries exist

        Supports two formats:
        1. Module name: "data" - validates _shared/python/data/ directory exists
        2. File paths: "data/_utils.py" - validates _shared/python/data/_utils.py file exists

        Args:
            function_dir: Directory containing the function
            yaml_data: Parsed function.yaml data

        Raises:
            ValidationError: If shared libraries are missing
        """
        # Find the gateway root (function_dir is at gateway/functions/<module>/<function>)
        gateway_root = function_dir.parent.parent.parent
        shared_root = gateway_root / "functions" / "_shared" / "python"

        if not shared_root.exists():
            # If _shared doesn't exist, we can't validate, but don't fail
            # (might be in a context where shared libs don't exist yet)
            return

        clouds = yaml_data.get("clouds", {})

        for cloud_name, cloud_config in clouds.items():
            shared_libs = cloud_config.get("shared_libs", [])

            for lib_name in shared_libs:
                if "/" in lib_name:
                    # Path format: "data/_utils.py" (file) or "data/utils/" (folder)
                    lib_path = shared_root / lib_name
                    if not lib_path.exists():
                        raise ValidationError(
                            f"Shared library path not found for {cloud_name}: {lib_name} "
                            f"(expected at {lib_path})"
                        )
                    if not lib_path.is_file() and not lib_path.is_dir():
                        raise ValidationError(
                            f"Shared library path is neither file nor directory for {cloud_name}: "
                            f"{lib_name} (at {lib_path})"
                        )

                    # Validate that __init__.py exists for the module
                    parts = lib_name.split("/", 1)
                    module_name = parts[0]
                    init_path = shared_root / module_name / "__init__.py"
                    if not init_path.exists():
                        raise ValidationError(
                            f"Shared library module missing __init__.py for {cloud_name}: "
                            f"{module_name}/ (required when using paths)"
                        )
                else:
                    # Module name format: "data" - validate directory exists
                    lib_path = shared_root / lib_name
                    if not lib_path.exists():
                        raise ValidationError(
                            f"Shared library not found for {cloud_name}: {lib_name} "
                            f"(expected at {lib_path})"
                        )
                    if not lib_path.is_dir():
                        raise ValidationError(
                            f"Shared library path is not a directory for {cloud_name}: {lib_name} "
                            f"(at {lib_path})"
                        )

    def validate_function(self, function_dir: Path) -> None:
        """
        Validate a complete function directory

        Args:
            function_dir: Path to function directory containing function.yaml

        Raises:
            ValidationError: If validation fails
        """
        yaml_path = function_dir / "function.yaml"

        if not yaml_path.exists():
            raise ValidationError(f"function.yaml not found in {function_dir}")

        # Load YAML
        with open(yaml_path, "r") as f:
            yaml_data = yaml.safe_load(f)

        # Run validations
        if self.schema:
            self.validate_yaml_structure(yaml_data)

        self.validate_code_files_exist(function_dir, yaml_data)
        self.validate_shared_libs_exist(function_dir, yaml_data)


def validate_all_functions(
    functions_dir: Path, schema_path: Optional[Path] = None
) -> List[str]:
    """
    Validate all functions in a directory

    Args:
        functions_dir: Root directory containing function modules
        schema_path: Optional path to schema file

    Returns:
        List of error messages (empty if all valid)
    """
    validator = FunctionValidator(schema_path)
    errors = []

    # Find all function.yaml files
    for yaml_file in functions_dir.rglob("function.yaml"):
        function_dir = yaml_file.parent
        function_name = function_dir.name

        try:
            validator.validate_function(function_dir)
        except ValidationError as e:
            errors.append(f"{function_name}: {str(e)}")
        except Exception as e:
            errors.append(f"{function_name}: Unexpected error - {str(e)}")

    return errors
