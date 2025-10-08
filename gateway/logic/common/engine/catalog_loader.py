"""
Loads function catalog from YAML files
Discovers and parses all functions in the gateway
"""

import yaml
from pathlib import Path
from typing import List, Dict, Optional, Set, Union
from .models import (
    Function,
    FunctionArgument,
    FunctionOutput,
    FunctionExample,
    CloudConfig,
    TestConfig,
    FunctionType,
    CloudType,
    PlatformType,
)


class CatalogLoader:
    """Loads and manages the function catalog"""

    def __init__(self, functions_root: Union[Path, List[Path]]):
        """
        Initialize catalog loader

        Args:
            functions_root: Root directory or list of directories containing
                function categories
        """
        if isinstance(functions_root, list):
            self.functions_roots = functions_root
        else:
            self.functions_roots = [functions_root]
        self._catalog: Dict[str, Function] = {}

    def discover_functions(self) -> List[Path]:
        """
        Discover all function.yaml files across all roots

        Returns:
            List of paths to function.yaml files
        """
        all_yamls = []
        for root in self.functions_roots:
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

        # Determine category from directory structure
        category = self._get_category(function_dir)

        # Parse arguments
        arguments = [
            FunctionArgument(
                name=arg["name"],
                type=arg["type"],
                description=arg.get("description", ""),
            )
            for arg in data.get("arguments", [])
        ]

        # Parse output
        output_data = data.get("output", {})
        output = FunctionOutput(
            name=output_data.get("name", "result"),
            type=output_data.get("type", "unknown"),
            description=output_data.get("description", ""),
        )

        # Parse examples
        examples = [
            FunctionExample(
                description=ex.get("description", ""),
                arguments=ex.get("arguments", []),
                output=ex.get("output"),
            )
            for ex in data.get("examples", [])
        ]

        # Parse cloud configurations
        clouds = {}
        for cloud_name, cloud_data in data.get("clouds", {}).items():
            try:
                cloud_type = CloudType(cloud_name)
                platform_type = PlatformType(cloud_data["type"])

                code_file = function_dir / cloud_data["code_file"]
                requirements_file = None
                if "requirements_file" in cloud_data:
                    requirements_file = function_dir / cloud_data["requirements_file"]

                template_file = None
                if "external_function_template" in cloud_data:
                    template_file = (
                        function_dir / cloud_data["external_function_template"]
                    )

                clouds[cloud_type] = CloudConfig(
                    type=platform_type,
                    code_file=code_file,
                    requirements_file=requirements_file,
                    external_function_template=template_file,
                    config=cloud_data.get("config", {}),
                )
            except (ValueError, KeyError) as e:
                print(
                    f"Warning: Skipping invalid cloud config '{cloud_name}' "
                    f"in {function_name}: {e}"
                )

        # Parse test configuration
        test_data = data.get("test", {})
        test_config = TestConfig(
            dataset=test_data.get("dataset"), timeout=test_data.get("timeout", 30)
        )

        # Set test file paths
        test_config.unit_test_cases = function_dir / "tests" / "unit" / "cases.yaml"
        test_config.unit_test_file = (
            function_dir / "tests" / "unit" / f"test_{function_name}.py"
        )
        test_config.integration_test_file = (
            function_dir / "tests" / "integration" / f"test_{function_name}.py"
        )

        return Function(
            name=function_name,
            function_type=FunctionType(data["function_type"]),
            author=data.get("author", "CARTO"),
            description=data.get("description", ""),
            arguments=arguments,
            output=output,
            examples=examples,
            clouds=clouds,
            test=test_config,
            category=category,
            function_path=function_dir,
        )

    def _get_category(self, function_dir: Path) -> str:
        """
        Determine category from directory structure

        Args:
            function_dir: Path to function directory

        Returns:
            Category name
        """
        # Category is the parent directory of the function
        # Try to find which root this function belongs to
        for root in self.functions_roots:
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

    def get_functions_by_category(self, category: str) -> List[Function]:
        """Get all functions in a category"""
        return [f for f in self._catalog.values() if f.category == category]

    def get_functions_by_cloud(self, cloud: CloudType) -> List[Function]:
        """Get all functions that support a specific cloud"""
        return [f for f in self._catalog.values() if f.supports_cloud(cloud)]

    def get_categories(self) -> Set[str]:
        """Get all unique categories"""
        return {f.category for f in self._catalog.values()}

    def get_all_functions(self) -> List[Function]:
        """Get all functions"""
        return list(self._catalog.values())

    @property
    def catalog(self) -> Dict[str, Function]:
        """Get the loaded catalog"""
        if not self._catalog:
            self.load_catalog()
        return self._catalog
