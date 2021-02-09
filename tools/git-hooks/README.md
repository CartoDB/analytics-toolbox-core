# Git hooks installation

In order to ensure code quality and formatting some git hooks are shared between contributors. Please, install them by following the next steps:

Check your git version:

```bash
git --version
```

For Git versions >= 2.9.

```bash
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath tools/git-hooks
```

For earlier versions.

```bash
cd "$(git rev-parse --show-toplevel)"
sh ./tools/git-hooks/install.sh
```
