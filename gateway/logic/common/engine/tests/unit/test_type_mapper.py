"""
Unit tests for TypeMapperRegistry

Tests the cloud-agnostic type mapping registry and Redshift provider
"""

import pytest
from ...type_mapper import TypeMapperRegistry, GenericType

# Import Redshift type mappings to register them
from logic.clouds.redshift import type_mappings  # noqa: F401


class TestTypeMapperRegistry:
    """Test TypeMapperRegistry functionality"""

    def test_registry_has_redshift_registered(self):
        """Test that Redshift is registered"""
        assert TypeMapperRegistry.is_registered("redshift")

    def test_registered_clouds_list(self):
        """Test getting list of registered clouds"""
        clouds = TypeMapperRegistry.registered_clouds()
        assert "redshift" in clouds

    def test_get_provider_for_valid_cloud(self):
        """Test getting provider for a registered cloud"""
        provider = TypeMapperRegistry.get_provider("redshift")
        assert provider is not None

    def test_get_provider_for_invalid_cloud(self):
        """Test getting provider for unregistered cloud raises error"""
        with pytest.raises(ValueError, match="No type mapper registered"):
            TypeMapperRegistry.get_provider("invalid_cloud")

    def test_map_string_to_redshift(self):
        """Test string maps to VARCHAR(MAX) in Redshift"""
        result = TypeMapperRegistry.map_type("string", "redshift")
        assert result == "VARCHAR(MAX)"

    def test_map_int_to_redshift(self):
        """Test int maps to INT in Redshift"""
        result = TypeMapperRegistry.map_type("int", "redshift")
        assert result == "INT"

    def test_map_bigint_to_redshift(self):
        """Test bigint maps to INT8 in Redshift"""
        result = TypeMapperRegistry.map_type("bigint", "redshift")
        assert result == "INT8"

    def test_map_object_to_redshift(self):
        """Test object maps to SUPER in Redshift"""
        result = TypeMapperRegistry.map_type("object", "redshift")
        assert result == "SUPER"

    def test_map_geometry_to_redshift(self):
        """Test geometry maps to GEOMETRY in Redshift"""
        result = TypeMapperRegistry.map_type("geometry", "redshift")
        assert result == "GEOMETRY"

    def test_map_geography_to_redshift(self):
        """Test geography maps to GEOGRAPHY in Redshift"""
        result = TypeMapperRegistry.map_type("geography", "redshift")
        assert result == "GEOGRAPHY"

    def test_map_boolean_to_redshift(self):
        """Test boolean maps to BOOLEAN in Redshift"""
        result = TypeMapperRegistry.map_type("boolean", "redshift")
        assert result == "BOOLEAN"

    def test_map_float_to_redshift(self):
        """Test float maps to FLOAT4 in Redshift"""
        result = TypeMapperRegistry.map_type("float", "redshift")
        assert result == "FLOAT4"

    def test_map_double_to_redshift(self):
        """Test double maps to FLOAT8 in Redshift"""
        result = TypeMapperRegistry.map_type("double", "redshift")
        assert result == "FLOAT8"

    def test_map_bytes_to_redshift(self):
        """Test bytes maps to VARBYTE in Redshift"""
        result = TypeMapperRegistry.map_type("bytes", "redshift")
        assert result == "VARBYTE"

    def test_cloud_specific_type_passthrough(self):
        """Test cloud-specific types are passed through unchanged"""
        # Already cloud-specific types should not be mapped
        result = TypeMapperRegistry.map_type("VARCHAR(MAX)", "redshift")
        assert result == "VARCHAR(MAX)"

        result = TypeMapperRegistry.map_type("INT8", "redshift")
        assert result == "INT8"

        result = TypeMapperRegistry.map_type("SUPER", "redshift")
        assert result == "SUPER"

    def test_unknown_type_passthrough(self):
        """Test unknown types are passed through as cloud-specific"""
        # In hybrid approach, unknown types are assumed to be cloud-specific
        # and passed through unchanged
        result = TypeMapperRegistry.map_type("CUSTOM_TYPE", "redshift")
        assert result == "CUSTOM_TYPE"

        result = TypeMapperRegistry.map_type("MY_SPECIAL_TYPE", "redshift")
        assert result == "MY_SPECIAL_TYPE"

    def test_case_insensitive_generic_types(self):
        """Test generic types are case-insensitive"""
        result1 = TypeMapperRegistry.map_type("string", "redshift")
        result2 = TypeMapperRegistry.map_type("STRING", "redshift")
        result3 = TypeMapperRegistry.map_type("String", "redshift")

        # All variations should map to VARCHAR(MAX) (case-insensitive)
        assert result1 == "VARCHAR(MAX)"
        assert result2 == "VARCHAR(MAX)"
        assert result3 == "VARCHAR(MAX)"

    def test_is_generic_type(self):
        """Test detection of valid generic types"""
        assert TypeMapperRegistry.is_generic_type("string", "redshift")
        assert TypeMapperRegistry.is_generic_type("int", "redshift")
        assert TypeMapperRegistry.is_generic_type("bigint", "redshift")
        assert TypeMapperRegistry.is_generic_type("object", "redshift")
        assert not TypeMapperRegistry.is_generic_type("VARCHAR(MAX)", "redshift")
        assert not TypeMapperRegistry.is_generic_type("invalid", "redshift")

    def test_get_supported_generic_types(self):
        """Test getting list of supported generic types for Redshift"""
        types = TypeMapperRegistry.get_supported_generic_types("redshift")

        assert "string" in types
        assert "int" in types
        assert "bigint" in types
        assert "float" in types
        assert "double" in types
        assert "boolean" in types
        assert "bytes" in types
        assert "object" in types
        assert "geometry" in types
        assert "geography" in types

    def test_all_generic_types_have_redshift_mappings(self):
        """Test all generic types have mappings for Redshift"""
        for generic_type in GenericType:
            # Should not raise
            result = TypeMapperRegistry.map_type(generic_type.value, "redshift")
            assert result is not None
            assert len(result) > 0


class TestRedshiftTypeMappings:
    """Test Redshift-specific type mappings"""

    def test_redshift_specific_mappings(self):
        """Test Redshift-specific type choices"""
        # Redshift uses INT8 for bigint (not BIGINT)
        assert TypeMapperRegistry.map_type("bigint", "redshift") == "INT8"

        # Redshift uses SUPER for object
        assert TypeMapperRegistry.map_type("object", "redshift") == "SUPER"

        # Redshift uses FLOAT4/FLOAT8 for float/double
        assert TypeMapperRegistry.map_type("float", "redshift") == "FLOAT4"
        assert TypeMapperRegistry.map_type("double", "redshift") == "FLOAT8"

        # Redshift uses VARCHAR(MAX) for string
        assert TypeMapperRegistry.map_type("string", "redshift") == "VARCHAR(MAX)"

        # Redshift uses VARBYTE for bytes
        assert TypeMapperRegistry.map_type("bytes", "redshift") == "VARBYTE"
