---
trigger: always_on
globs: **/*.py
paths: **/*.py
---

# General Rules
- By default, new code should exhibit similarity to other pre-existing code. The response structure, parameters, etc., should be structured similarly by referencing other code.
- Backward compatibility is not a concern. This project is not a live service. When making changes, remove everything unnecessary.

# Function Rules

## Parameters
A function accepts a maximum of three parameters (excluding `self`). If you need more parameters, you must create a Pydantic model for the function's parameters. The class should be named `FunctionNameParams`. If you can use the same parameter class for two functions that are part of a similar family of behaviors, you should name the parameters with a name that encompasses both functions. It should still be suffixed with `Params`.

### EXCEPTION
However, Constructor functions (`__init__`) that should be used for dependency injection by `dependency-injector` should take multiple inputs without defining a Parameter class.

# Combined Python Style Guide
If you don't violate any of the above rules, follow the rules in the link below. If there is a conflict, follow the order of precedence from the top first

- PEP 8 (https://peps.python.org/pep-0008/)
- Ruff formatting rules
- pyright type checking (strict mode)
- Google Python Style Guide (https://google.github.io/styleguide/pyguide.html)

# Python Version
- Target Python 3.13+ to use modern features like `Self`, `StrEnum`, and union type syntax (`T | None`)
