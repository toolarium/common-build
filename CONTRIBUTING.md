# Contributing to common-build

Thank you for your interest in contributing to common-build! This document explains how to get started.


## Development setup

1. Clone the repository:
   ```bash
   git clone https://github.com/toolarium/common-build.git
   cd common-build
   ```

2. Make scripts executable (Linux/macOS):
   ```bash
   chmod -R +x bin/ test/bin/
   ```

3. Run the tests to verify your setup:
   ```bash
   bash test/bin/cb-test
   ```

See [TESTING.md](TESTING.md) for the full test suite and how to run it.


## Project structure

- `bin/cb` / `bin/cb.bat` — main entry points (shell / Windows batch)
- `bin/packages/<name>/` — package-specific install scripts
- `bin/include/` — shared helper scripts
- `conf/` — configuration files (tool versions, project types)
- `test/bin/` — test scripts (cross-platform pairs: shell + `.bat`)
- `docs/` — documentation pages


## How to contribute

### Reporting bugs

Open an [issue](https://github.com/toolarium/common-build/issues) using the bug report template. Include:
- Operating system and version
- Steps to reproduce
- Expected vs. actual behavior
- Console output (if applicable)

### Suggesting features

Open an [issue](https://github.com/toolarium/common-build/issues) using the feature request template.

### Submitting changes

1. Fork the repository and create a branch from `master`.
2. Make your changes following the coding conventions below.
3. Add or update tests for your changes (see below).
4. Update `CHANGELOG.md` under the `[Unreleased]` section.
5. Ensure all tests pass.
6. Submit a pull request.


## Coding conventions

### Cross-platform

Every user-facing script must have both a shell version and a `.bat` version. When adding a new tool or feature, ensure it works on both Linux/macOS and Windows.

### Shell scripts

- Use `#!/bin/bash` shebang
- Use POSIX-compatible constructs where possible
- Quote all variable expansions: `"$var"` not `$var`
- Redirect errors to `/dev/null` for optional operations: `cmd >/dev/null 2>&1`

### Batch scripts

- Use `@ECHO OFF` and `setlocal EnableDelayedExpansion`
- Use CRLF line endings (enforced by `.gitattributes`)
- Use `>nul 2>nul` for suppressed output

### Adding a new package

1. Create `bin/packages/<name>/<name>.bat` and `<name>.sh`
2. Set `CB_PACKAGE_ALREADY_EXIST=true` when target directory exists
3. Add the default version to `conf/tool-version-default.properties`
4. Add the tool to PATH in **both** `--setenv` and `COMMON_BUILD` paths in `cb`/`cb.bat`
5. Add a test under `test/bin/`
6. Update the Supported Packages table in `README.md`


## Versioning and compatibility

This project follows [Semantic Versioning](https://semver.org/):

| Version part | When to increment | Compatibility guarantee |
|---|---|---|
| **Patch** (1.0.**x**) | Bug fixes, documentation updates, internal refactoring | Fully backward compatible. No user-visible behavior changes. Existing scripts, environment variables, and configurations continue to work identically. |
| **Minor** (1.**x**.0) | New features, new packages, new options, new utility scripts | Backward compatible. All existing functionality continues to work. New features are additive only — no removal or change of existing behavior. |
| **Major** (**x**.0.0) | Breaking changes | May break backward compatibility. Examples: renamed/removed options, changed default behavior, removed packages, changed environment variable semantics, restructured configuration files. |

When submitting a change, consider which category it falls into:

- **Patch**: fixing a bug in `trivy.sh`, correcting a typo in help output, improving error handling without changing behavior.
- **Minor**: adding a new package (`bin/packages/newtools/`), adding a new `cb` option, adding a new utility script.
- **Major**: renaming `--setenv` to something else, changing the `tool-version-default.properties` format, removing support for a platform.

If your change introduces a breaking change, clearly document it in your pull request and the `CHANGELOG.md` entry.


## Testing

All changes should include tests. Test scripts live in `test/bin/` as cross-platform pairs (shell + `.bat`).

**Key rules:**
- Tests must create a sandbox `CB_HOME` under `$TMPDIR`/`%TEMP%` — never use the project directory
- Tests must clean up after themselves
- Tools are always installed via `cb --install <tool> --default` into the sandbox

Run the full suite:
```bash
bash test/bin/cb-test
bash test/bin/cb-project-test
bash test/bin/cb-clean-files-test
bash test/bin/cb-open-ports-test
bash test/bin/cb-versionfilter-test
bash test/bin/cb-install-test
CB_INSTALL_TEST_E2E=1 bash test/bin/cb-install-e2e-test
```

See [TESTING.md](TESTING.md) for detailed documentation.


## License

By contributing, you agree that your contributions will be licensed under the [GNU General Public License v3](LICENSE).
