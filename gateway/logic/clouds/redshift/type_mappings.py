"""
Redshift-specific type mappings

Maps generic types to Redshift SQL types for external function definitions.
"""

from ...common.engine.type_mapper import TypeMapperRegistry


class RedshiftTypeMappings:
    """
    Redshift-specific type mapping provider

    Maps generic types (string, int, etc.) to Redshift SQL types
    (VARCHAR(MAX), INT, INT8, SUPER, etc.)
    """

    # Generic type → Redshift SQL type
    TYPE_MAPPINGS = {
        "string": "VARCHAR(MAX)",
        "int": "INT",
        "bigint": "INT8",
        "float": "FLOAT4",
        "double": "FLOAT8",
        "boolean": "BOOLEAN",
        "bytes": "VARBYTE",
        "object": "SUPER",
        "geometry": "GEOMETRY",
        "geography": "GEOGRAPHY",
    }

    def map_type(self, generic_type: str) -> str:
        """
        Map a generic type to Redshift SQL type

        Args:
            generic_type: Generic type (e.g., "string", "int") or
                         Redshift-specific type (e.g., "VARCHAR(MAX)", "SUPER")

        Returns:
            Redshift SQL type
        """
        # Check if it's a generic type (case-insensitive)
        generic_lower = generic_type.lower()
        if generic_lower in self.TYPE_MAPPINGS:
            return self.TYPE_MAPPINGS[generic_lower]

        # Not a generic type, assume it's already Redshift-specific
        # (e.g., "VARCHAR(MAX)", "SUPER", "INT8")
        return generic_type

    def is_generic_type(self, type_str: str) -> bool:
        """
        Check if a type string is a recognized generic type

        Args:
            type_str: Type string to check

        Returns:
            True if recognized generic type, False otherwise
        """
        return type_str.lower() in self.TYPE_MAPPINGS

    def get_supported_generic_types(self) -> list[str]:
        """
        Get list of supported generic types

        Returns:
            List of generic type strings
        """
        return list(self.TYPE_MAPPINGS.keys())


# Auto-register this mapper when the module is imported
_redshift_mapper = RedshiftTypeMappings()
TypeMapperRegistry.register("redshift", _redshift_mapper)
