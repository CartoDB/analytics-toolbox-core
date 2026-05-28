---
paths:
  - "gateway/logic/**"
---

# Extending Cloud Support

The gateway uses a registry pattern for cloud-specific type mappings, allowing new clouds to be added without modifying core code.

## Type Mapping Architecture

**TypeMapperRegistry** (`gateway/logic/common/engine/type_mapper.py`):
- Cloud-agnostic registry maintaining type mapping providers
- Each cloud registers its own TypeMappingProvider implementation
- Provides unified interface: `TypeMapperRegistry.map_type("string", "redshift")` -> `"VARCHAR(MAX)"`

## Adding a New Cloud

To add support for a new cloud (e.g., BigQuery, Snowflake):

### 1. Create cloud-specific type mappings

```python
# gateway/logic/clouds/bigquery/type_mappings.py
from ...common.engine.type_mapper import TypeMapperRegistry

class BigQueryTypeMappings:
    """BigQuery-specific type mapping provider"""

    TYPE_MAPPINGS = {
        "string": "STRING",
        "int": "INT64",
        "bigint": "INT64",
        "float": "FLOAT64",
        "double": "FLOAT64",
        "boolean": "BOOL",
        "bytes": "BYTES",
        "object": "JSON",
        "geometry": "GEOGRAPHY",  # BigQuery uses GEOGRAPHY for spatial
        "geography": "GEOGRAPHY",
    }

    def map_type(self, generic_type: str) -> str:
        """Map generic type to BigQuery SQL type"""
        generic_lower = generic_type.lower()
        if generic_lower in self.TYPE_MAPPINGS:
            return self.TYPE_MAPPINGS[generic_lower]
        return generic_type  # Already cloud-specific

    def is_generic_type(self, type_str: str) -> bool:
        """Check if type is generic"""
        return type_str.lower() in self.TYPE_MAPPINGS

    def get_supported_generic_types(self) -> list[str]:
        """Get supported generic types"""
        return list(self.TYPE_MAPPINGS.keys())

# Auto-register when module is imported
_bigquery_mapper = BigQueryTypeMappings()
TypeMapperRegistry.register("bigquery", _bigquery_mapper)
```

### 2. Update CloudType enum

```python
# gateway/logic/common/engine/models.py
class CloudType(Enum):
    """Supported cloud platforms"""
    REDSHIFT = "redshift"
    BIGQUERY = "bigquery"  # Add new cloud
```

### 3. Import the mapping in your cloud CLI

```python
# gateway/logic/clouds/bigquery/cli.py
from .type_mappings import BigQueryTypeMappings  # Triggers auto-registration
```

### 4. Implement cloud-specific deployment logic

- SQL template generator (like `RedshiftSQLTemplateGenerator`)
- Template renderer for cloud-specific SQL syntax
- CLI commands for deployment
- Pre-flight checks and validation

## Current Implementation

**Redshift** (`gateway/logic/clouds/redshift/type_mappings.py`):
- Implements `RedshiftTypeMappings` class
- Maps generic types to Redshift SQL types (VARCHAR(MAX), INT8, SUPER, etc.)
- Auto-registers on import via `TypeMapperRegistry.register("redshift", ...)`

## Future Development Guidelines

**When adding new functions:**

1. Determine if code should be shared or function-specific
2. Use shared library only if used by 2+ functions
3. Keep lambda_name <=18 characters
4. Add comprehensive unit tests
5. Use generic types in function.yaml when possible
6. Follow existing handler patterns
7. Build and test before committing

**When modifying shared libraries:**

1. Consider impact on all dependent functions
2. Run tests for all dependent functions
3. Avoid breaking changes
4. Update shared library documentation
5. Rebuild all dependent functions

**When refactoring:**

1. Maintain backward compatibility
2. Keep function signatures unchanged
3. Update tests to match changes
4. Verify deployment after refactoring
5. Document architectural decisions
