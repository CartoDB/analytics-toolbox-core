# How to contribute?

## Pull requests

Every change in the Analytics Toolbox must be included in a pull request. It will be merged by squashing the commits, resulting in one commit against `main` that uses the pull request name and number in the commit description.

The pull request must have a good name and description. We recommend following [Conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) for the naming, which helps have a more structured and descriptive git tree.

These are the main types to be used: `feat`, `fix`, `doc`, `test`, `chore`, and `refactor`, but others can also be used if needed.

The scope is included to refer to the cloud or clouds (`bq`, `sf`, `rs`, `pg`, `db`), and the module or modules affected (`h3`, `lds`, etc.). The format of the scope will be as follows:

```
(<cloud(s)>|<module(s)>)
```

Here there are some examples:

```
feat(bq,sf,rs,pg|quadbin): add quadbin/quadkey conversion functions
```

```
fix(sf|lds): decrease isolines batch size
```

## Documentation

The Analytics Toolbox repositories include all the SQL references for each function/procedure in all the modules. This is the source data for the public SQL reference in the documentation: https://docs.carto.com/data-and-analysis/analytics-toolbox-overview.

### Structure

This is the structure of a generic doc folder:

```
clouds/<cloud>/modules/doc/<module>/
- _INTRO.md
- FUNCTION_A.md
- PROCEDURE_B.md
```

The language for documentation is Markdown extended with new metadata and special markers. Here is a guide to contributing to the documentation:

**Introduction**

The file *_INTRO.md* contains the introduction of the module's documentation. The template could vary for each cloud provider.

It allows passing a yml-like metadata header with the following information:
- badges: core, advanced, beta, etc.
- order (optional): list of the functions/procedures. By default, it sorts by alphabetical order.

```md
---
badges:
- advanced
- beta
order:
- PROCEDURE_B
- FUNCTION_A
---

# module

Description of the module.
```

**Function**

````md
## FUNCTION_A

```sql:signature
FUNCTION_A(param_a, param_b)
```

**Description**

Description of the function.

* `param_a`: `STRING` description of param a.
* `param_b` (optional): `INT64` description of param b.

**Return type**

`FLOAT64`

**Example**

```sql
SELECT carto.FUNCTION_A('a', 123);
-- 1234.0
```
````

**Procedure**

````md
## PROCEDURE_B

```sql:signature
PROCEDURE_B(param_a, param_b)
```

**Description**

Description of the procedure.

* `param_a`: `STRING` description of param a.
* `param_b` (optional): `FLOAT64` description of param b.

**Output**

The result is a table with ...

**Example**

```sql
CALL carto.PROCEDURE_B(
  '''
  SELECT * ...
  ''',
  123
);
```
````

### Extras

Additionally, the documentation allows hint blocks (info/warning):

**Hints**

`````
````hint:info
**Title**
...
````
`````

Links to other functions or procedures must follow the next template:

```md
[`FUNCTION_NAME`](module_name#function_name)
```

```md
[`QUADBIN_BOUNDARY`](quadbin#quadbin_boundary)
```

For external links, include the full address, for example:

```md
Please check our [documentation for Developers](https://docs.carto.com/carto-user-manual/developers)
```