"""
Loads function catalog from YAML files
Discovers and parses all functions in the gateway
"""

import yaml
from pathlib import Path
from typing import List, Dict, Optional, Set, Union
from .models import (
    Function,
    CloudConfig,
    CloudType,
    PlatformType,
    FunctionParameter,
)


class CatalogLoader:
    """Loads and manages the function catalog"""

    def __init__(self, function_roots: Union[Path, List[Path]]):
        """
        Initialize catalog loader

        Args:
            function_roots: Root directory or list of directories containing
                function modules
        """
        if isinstance(function_roots, list):
            self.function_roots = function_roots
        else:
            self.function_roots = [function_roots]
        self._catalog: Dict[str, Function] = {}

    def discover_functions(self) -> List[Path]:
        """
        Discover all function.yaml files across all roots

        Returns:
            List of paths to function.yaml files
        """
        all_yamls = []
        for root in self.function_roots:
            all_yamls.extend(root.rglob("function.yaml"))
        return all_yamls

    def load_function(self, yaml_path: Path) -> Function:
        """
        Load a single function from its YAML file

        Args:
            yaml_path: Path to function.yaml

        Returns:
            Function object
        """
        with open(yaml_path, "r") as f:
            data = yaml.safe_load(f)

        function_dir = yaml_path.parent
        function_name = function_dir.name

        # Determine module from directory structure
        module = self._get_module(function_dir)

        # Parse top-level parameters and return type (generic definitions)
        generic_parameters = self._parse_parameters(data.get("parameters"))
        generic_return_type = data.get("returns")

        # Parse cloud configurations
        clouds = {}
        for cloud_name, cloud_data in data.get("clouds", {}).items():
            try:
                cloud_type = CloudType(cloud_name)
                platform_type = PlatformType(cloud_data["type"])

                # code_file is now optional (for SQL-only functions)
                code_file = None
                if "code_file" in cloud_data:
                    code_file = function_dir / cloud_data["code_file"]

                requirements_file = None
                if "requirements_file" in cloud_data:
                    requirements_file = function_dir / cloud_data["requirements_file"]

                template_file = None
                if "external_function_template" in cloud_data:
                    template_file = (
                        function_dir / cloud_data["external_function_template"]
                    )

                # Get optional lambda_name override
                lambda_name = cloud_data.get("lambda_name")

                # Parse cloud-specific parameters and return type (overrides)
                cloud_parameters = self._parse_parameters(cloud_data.get("parameters"))
                cloud_return_type = cloud_data.get("returns")

                clouds[cloud_type] = CloudConfig(
                    type=platform_type,
                    code_file=code_file,
                    requirements_file=requirements_file,
                    external_function_template=template_file,
                    lambda_name=lambda_name,
                    parameters=cloud_parameters,
                    returns=cloud_return_type,
                    config=cloud_data.get("config", {}),
                )
            except (ValueError, KeyError) as e:
                print(
                    f"Warning: Skipping invalid cloud config '{cloud_name}' "
                    f"in {function_name}: {e}"
                )

        function = Function(
            name=function_name,
            clouds=clouds,
            module=module,
            function_path=function_dir,
            description=data.get("description", "CARTO Analytics Toolbox function"),
            parameters=generic_parameters,
            returns=generic_return_type,
        )

        # Validate function configuration
        self._validate_function(function)

        return function

    def _parse_parameters(
        self, params_data: Optional[List[Dict]]
    ) -> List[FunctionParameter]:
        """
        Parse parameter definitions from YAML

        Args:
            params_data: List of parameter dictionaries from YAML

        Returns:
            List of FunctionParameter objects, or empty list if no parameters
        """
        if not params_data:
            return []

        parameters = []
        for param in params_data:
            parameters.append(
                FunctionParameter(
                    name=param["name"],
                    type=param["type"],
                    description=param.get("description"),
                )
            )
        return parameters

    def _validate_function(self, function: Function) -> None:
        """
        Validate function configuration

        Ensures function has either:
        - SQL template file (legacy), OR
        - Parameters and return type (for auto-generation)

        Args:
            function: Function to validate

        Raises:
            ValueError: If function configuration is invalid
        """
        for cloud, cloud_config in function.clouds.items():
            # Get resolved return type
            return_type = function.get_resolved_return_type(cloud)

            # Check if function has SQL template
            has_template = (
                cloud_config.external_function_template is not None
                and cloud_config.external_function_template.exists()
            )

            # Check if function has metadata for auto-generation
            # Only return_type is required; parameters can be empty list
            has_metadata = return_type is not None

            # At least one must be true
            if not has_template and not has_metadata:
                print(
                    f"Warning: Function {function.name} ({cloud.value}) has neither "
                    f"SQL template nor parameters/returns metadata. "
                    f"Provide either external_function_template or parameters/returns."
                )

    def _get_module(self, function_dir: Path) -> str:
        """
        Determine module from directory structure

        Args:
            function_dir: Path to function directory

        Returns:
            Module name
        """
        # Module is the parent directory of the function
        # Try to find which root this function belongs to
        for root in self.function_roots:
            try:
                relative_path = function_dir.relative_to(root)
                if len(relative_path.parts) > 1:
                    return relative_path.parts[0]
                return "general"
            except ValueError:
                # Not relative to this root, try next
                continue
        # Fallback
        return "general"

    def load_catalog(self) -> Dict[str, Function]:
        """
        Load all functions into catalog

        Returns:
            Dictionary mapping function name to Function object
        """
        self._catalog = {}

        for yaml_path in self.discover_functions():
            try:
                function = self.load_function(yaml_path)
                self._catalog[function.name] = function
            except Exception as e:
                print(f"Error loading {yaml_path}: {e}")

        return self._catalog

    def get_function(self, name: str) -> Optional[Function]:
        """Get a function by name"""
        return self._catalog.get(name)

    def get_functions_by_module(self, module: str) -> List[Function]:
        """Get all functions in a module"""
        return [f for f in self._catalog.values() if f.module == module]

    def get_functions_by_cloud(self, cloud: CloudType) -> List[Function]:
        """Get all functions that support a specific cloud"""
        return [f for f in self._catalog.values() if f.supports_cloud(cloud)]

    def get_modules(self) -> Set[str]:
        """Get all unique modules"""
        return {f.module for f in self._catalog.values()}

    def get_all_functions(self) -> List[Function]:
        """Get all functions"""
        return list(self._catalog.values())

    @property
    def catalog(self) -> Dict[str, Function]:
        """Get the loaded catalog"""
        if not self._catalog:
            self.load_catalog()
        return self._catalog
