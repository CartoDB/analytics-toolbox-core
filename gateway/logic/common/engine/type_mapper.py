"""
Type mapping registry for Analytics Toolbox functions

Cloud-agnostic interface for mapping generic types to cloud-specific SQL types.
Each cloud provides its own type mapping implementation.
"""

from abc import abstractmethod
from enum import Enum
from typing import Dict, Protocol


class TypeMappingProvider(Protocol):
    """
    Interface for cloud-specific type mapping providers

    Each cloud implements this protocol to provide its type mappings.
    """

    @abstractmethod
    def map_type(self, generic_type: str) -> str:
        """
        Map a generic type to cloud-specific SQL type

        Args:
            generic_type: Generic type string (e.g., "string", "int") or
                         cloud-specific type (e.g., "VARCHAR(MAX)", "SUPER")

        Returns:
            Cloud-specific SQL type
        """
        ...

    @abstractmethod
    def is_generic_type(self, type_str: str) -> bool:
        """
        Check if a type string is a recognized generic type

        Args:
            type_str: Type string to check

        Returns:
            True if recognized generic type, False otherwise
        """
        ...

    @abstractmethod
    def get_supported_generic_types(self) -> list[str]:
        """
        Get list of supported generic types

        Returns:
            List of generic type strings
        """
        ...


class TypeMapperRegistry:
    """
    Cloud-agnostic registry for type mapping providers

    This registry maintains a mapping of cloud names to their type mapping
    providers. It provides a unified interface for type mapping without
    knowing about specific cloud implementations.

    Usage:
        # Register a cloud-specific mapper (done in cloud module)
        TypeMapperRegistry.register("redshift", RedshiftTypeMappings())

        # Map a type
        sql_type = TypeMapperRegistry.map_type("string", "redshift")
        # Returns: "VARCHAR(MAX)"
    """

    _providers: Dict[str, TypeMappingProvider] = {}

    @classmethod
    def register(cls, cloud: str, provider: TypeMappingProvider) -> None:
        """
        Register a type mapping provider for a cloud

        Args:
            cloud: Cloud identifier (e.g., "redshift", "bigquery")
            provider: Type mapping provider implementing TypeMappingProvider protocol
        """
        cls._providers[cloud] = provider

    @classmethod
    def get_provider(cls, cloud: str) -> TypeMappingProvider:
        """
        Get type mapping provider for a cloud

        Args:
            cloud: Cloud identifier

        Returns:
            Type mapping provider for the cloud

        Raises:
            ValueError: If no provider registered for cloud
        """
        if cloud not in cls._providers:
            available = list(cls._providers.keys())
            raise ValueError(
                f"No type mapper registered for '{cloud}'. "
                f"Available: {available}. "
                f"Make sure the cloud module is imported to register its mapper."
            )
        return cls._providers[cloud]

    @classmethod
    def map_type(cls, generic_type: str, cloud: str) -> str:
        """
        Map a generic type to cloud-specific SQL type

        Args:
            generic_type: Generic type string or cloud-specific type
            cloud: Target cloud platform

        Returns:
            Cloud-specific SQL type

        Raises:
            ValueError: If no mapper registered for cloud
        """
        provider = cls.get_provider(cloud)
        return provider.map_type(generic_type)

    @classmethod
    def is_generic_type(cls, type_str: str, cloud: str) -> bool:
        """
        Check if a type string is a generic type for a specific cloud

        Args:
            type_str: Type string to check
            cloud: Cloud to check against

        Returns:
            True if generic type, False otherwise
        """
        provider = cls.get_provider(cloud)
        return provider.is_generic_type(type_str)

    @classmethod
    def get_supported_generic_types(cls, cloud: str) -> list[str]:
        """
        Get list of supported generic types for a cloud

        Args:
            cloud: Cloud to query

        Returns:
            List of generic type strings
        """
        provider = cls.get_provider(cloud)
        return provider.get_supported_generic_types()

    @classmethod
    def is_registered(cls, cloud: str) -> bool:
        """
        Check if a cloud has a registered type mapper

        Args:
            cloud: Cloud identifier

        Returns:
            True if registered, False otherwise
        """
        return cloud in cls._providers

    @classmethod
    def registered_clouds(cls) -> list[str]:
        """
        Get list of clouds with registered type mappers

        Returns:
            List of cloud identifiers
        """
        return list(cls._providers.keys())


class GenericType(Enum):
    """
    Standard generic types supported across clouds

    NOTE: This is for reference only. Actual type support is determined
    by each cloud's TypeMappingProvider implementation.
    """

    STRING = "string"
    INT = "int"
    BIGINT = "bigint"
    FLOAT = "float"
    DOUBLE = "double"
    BOOLEAN = "boolean"
    BYTES = "bytes"
    OBJECT = "object"  # JSON/SUPER/VARIANT
    GEOMETRY = "geometry"
    GEOGRAPHY = "geography"


# Backward compatibility alias
TypeMapper = TypeMapperRegistry
