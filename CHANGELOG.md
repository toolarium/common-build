# common-build

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-04-06
### Added
- GraalVM Community Edition support (`bin/packages/graalvm/graalvm.bat` and `graalvm.sh`) with platform-specific downloads for Windows, Linux and macOS. Default version: 21.0.2.
- Added GraalVM to PATH and `GRAALVM_HOME` configuration in `cb --setenv` for both shell and Windows batch.
- Automatic installation of Visual Studio 2022 Build Tools with C++ workload on Windows when installing GraalVM, required for Native Image compilation.
- Nushell support: `cb --setenv --nushell` outputs Nushell-compatible environment variable syntax (`$env.VAR = ...`). Installer (`cb-install`) auto-detects Nushell and creates `~/.config/nushell/cb-setenv.nu` with a source line in `env.nu`.
- New utility scripts (cross-platform, shell + `.bat`):
  - `cb-dockterm` — open an interactive terminal inside a running Docker container (types configurable via `conf/dockterm-types.properties`).
  - `cb-meminfo` — print host memory usage information.
  - `cb-open-ports` — list all open TCP/UDP ports with optional filter arguments.
  - `cb-version-filter` — filter semver version lists by major-version and previous-major patch thresholds (stdin, file or `--path`).
  - `cb-cleanup` — cleanup common-build artifacts (caches, temp directories, stale downloads). Calls `cleanup-start` / `cleanup-end` lifecycle hooks if a custom hook script is configured.
  - `cb-filetail` — follow/tail a file with optional grep filtering, cross-platform.
- Corresponding tests under `test/bin/` for `cb-test` (core cb options), `cb-project-test` (all 13 project types with optional build verification), `cb-clean-files`, `cb-open-ports`, `cb-version-filter`, `cb-dockterm`, `cb-meminfo`, `cb-cleanup`, `cb-filetail`, `cb-copysymlink`, `cb-deltree`, `cb-timestamp`, `cb-download`, `cb-update-custom-home` (mock git repo), `cb-read-version`, `cb-lock-unlock`, `cb-install` (help/version), and `cb-install-e2e` (end-to-end install with backup management verification).
- `CB_INSTALL_NO_PERSIST` environment variable for `cb-install.bat` to prevent writing to user registry (`setx`) during automated testing.
- Utility Scripts section in README and `docs/index.html` documenting all standalone helper scripts.
- New documentation: [Testing](TESTING.md) and `docs/testing.html` with full description of test architecture, sandbox isolation, gated CI strategy, environment variables, and local/CI usage.
- GitHub Actions workflow `cb-test.yml` for automated cross-platform test execution (Linux + Windows) with nightly full build matrix.
- GitHub Actions workflow `cb-release.yml` for manual release publishing with version validation, full test gate, archive building (excluding dev files), and GitHub release creation. Requires environment approval. Supports dry-run mode. Tags are immutable — a released version cannot be reused.
### Changed
- `cb-install` backup management: shell profile backups (`.bashrc`, `.zshrc`, etc.) now keep the 3 most recent backups next to the profile file and move older backups to `$CB_HOME/backup/`. Backups are deleted when no change was made.
- `cb-install` / `cb-install.bat` post-extraction cleanup now removes `test/` directories while keeping `docs/` (ships release documentation).
- `cb-meminfo` now supports macOS (uses `sysctl` for total memory, `ps` for process memory).
- `cb-open-ports` now supports macOS (uses `lsof` instead of `netstat`).
- Improved macOS compatibility across shell scripts: replaced GNU-specific `sed -i`, `stat -c`, `[[ ]]`, `=~`, `find -delete`, and `od -d` with portable alternatives.
- CI workflow `cb-test.yml` now runs shell tests on both Linux and macOS via matrix strategy.
- Replaced old `cb-test.yml` workflow (renamed to `cb-test-installation.yml`, disabled) with the new test-script-based `cb-test.yml`.
- Significantly improved `cb --setenv` / `cb.bat --setenv` performance by skipping all network operations (internet ping, host connection check, git fetch/clone) and using only cached custom config data. This makes `. cb --setenv` suitable for shell initialization without noticeable delay.
- Added quick check in `update-cb-custom-home.sh` and `.bat` that compares the `VERSION` file against the remote before performing a full clone. If VERSION is unchanged, the update is skipped entirely, avoiding the expensive `git clone` on every daily check.
- Rewrote README with improved introduction, key features overview, and links to new documentation pages.
- New documentation: [Project Wizard](docs/project-wizard.md) with full syntax reference for `project-types.properties`, `product-types.properties`, parameter substitution tokens, and all available project types.
- New documentation: [Organization Config](docs/organization-config.md) covering custom config setup, `.cb-custom-config` file, lifecycle hooks, concrete hook script examples for both Linux/Mac and Windows, and environment variables.
- Moved sample scripts from `bin/sample/` to `docs/sample/` and linked from README, organization-config and index.html documentation.

### Fixed
- Fixed `exit` → `return` in cb-custom sample validation hooks (`cb-custom-sample.sh`, `cb-custom.sh`) — `exit` inside a sourced script terminates the calling shell.
- Fixed `del` → `rm -f` in `cb-custom-sample.sh` (`customNewProjectEnd`).
- Fixed unquoted `$*` → `"$@"` in cb-custom sample/template shell scripts to handle arguments with spaces correctly.
- Changed cb-custom unknown-parameter handler to silently succeed instead of printing an error, for forward compatibility with new hooks.
- `cb --verbose --setenv` and `cb --force --setenv` now correctly apply the fast `--setenv` path on both Linux/Mac and Windows. Previously, prefixed arguments like `--verbose` or `--force` prevented the `--setenv` optimization from being detected.
- Fixed `update-cb-custom-home` quick check to use `git -C` with the correct repository path instead of relying on the current working directory.
- Fixed `update-cb-custom-home` quick check to gracefully skip on first-ever run when no local clone exists yet.
- Fixed `update-cb-custom-home.bat` quick check early exit to properly export `CB_CUSTOM_CONFIG_VERSION` to the caller instead of exporting an empty value.
- Fixed `update-cb-custom-home` quick check to gracefully skip when no upstream tracking branch is configured (`@{u}` not set).

## [1.0.12] - 2026-03-29
### Fixed
- Version bump only (no functional code changes).

## [1.0.11] - 2026-03-29
### Changed
- Extracted custom config settings logic into new `applyCustomConfigSettings()` function in `cb` shell script for better code reuse.
- Added `CB_CUSTOM_SETTING_SCRIPT` variable assignment in `cb.bat` for consistency between platforms.

### Fixed
- Fixed shell script exit behavior: added `return 0 2>/dev/null || exit 0` to properly handle both sourced and executed contexts.

## [1.0.10] - 2026-03-29
### Changed
- Added Trivy to PATH configuration in `cb --setenv` for both shell and Windows batch.
- Implemented `CB_PACKAGE_ALREADY_EXIST` check for Trivy installation to prevent re-extraction over existing directories.

### Fixed
- Fixed Trivy package installation following the `CB_PACKAGE_ALREADY_EXIST` pattern from `git.bat`.

## [1.0.9] - 2026-03-23
### Changed
- Updated Trivy from 0.68.2 to 0.69.2.

### Fixed
- Fixed `trivy.sh`: corrected variable references for macOS filename construction and platform-specific downloads.
- Added proper exports for `CB_PACKAGE_VERSION_NAME` and `CB_PACKAGE_DEST_VERSION_NAME` in Trivy shell script.

## [1.0.8] - 2026-03-16
### Fixed
- Corrected output redirection syntax in `lock-unlock.bat` (`>nul 2>nul`).

## [1.0.7] - 2026-02-27
### Changed
- Replaced all remaining deprecated `wmic` calls with PowerShell equivalents across `cb-install.bat`, `cb.bat`, `lock-unlock.bat`, and `getpid.bat`. Improves compatibility with Windows 11 where WMI is deprecated.
- Simplified `getpid.bat` to use only PowerShell for process ID retrieval.
- Updated lock/unlock mechanism to use `getpid.bat`.

## [1.0.6] - 2025-12-18
### Added
- Trivy vulnerability scanner support (`bin/packages/trivy/trivy.bat` and `trivy.sh`) with platform-specific downloads for deb, rpm, and tar.gz formats. Default version: 0.68.2.
- Added Trivy to PATH setup in both `cb` and `cb.bat`.

### Changed
- Updated Git from 2.49.0 to 2.52.0.
- Added `getpid.bat` utility for cross-platform process ID retrieval using PowerShell.
- Updated installer version from 0.9.3 to 1.0.4.

## [1.0.5] - 2025-12-09
### Changed
- Reorganized project template configuration in `project-types.properties`.
- Renamed project template `docker` to `container` (more generic for multiple container platforms).
- Updated Nuxt template from `nuxi init` to `npm create nuxt`.
- Added `documentation` project template.
- Removed mandatory suffixes from some templates (e.g., java-application no longer requires `-app` suffix).

## [1.0.4] - 2025-09-18
### Changed
- Replaced shortened `git.io` URL with full GitHub raw content URL in project wizard Gradle reference.
- Replaced deprecated WMI (`wmic`) calls with PowerShell in `cb-install-check.bat` for timestamp generation.

## [1.0.3] - 2025-05-01
### Changed
- Major tool version updates across all default packages:
  - Ant: 1.10.14 to 1.10.15
  - Eclipse: 2023-12 to 2025-03
  - Gradle: 8.5 to 8.13
  - IntelliJ: 2023.3 to 2024.3.5
  - Maven: 3.9.6 to 3.9.9
  - Micronaut: 4.2.1 to 4.8.0
  - Node: 20.10.0 to 22.14.0
  - Python: 3.12.1 to 3.13.2
  - VSCode: 1.85.0 to 1.99.0
  - Git: 2.43.0 to 2.49.0
  - Multi Commander: 13.3.0.2969 to 15.2.0.3077
  - and others (BTrace, JMeter, SBT, Squirrel, VisualVM, WinMerge, Ranger)
- Renamed `cb-clean` scripts to `cb-clean-files`.

## [1.0.2] - 2025-01-30
### Changed
- Renamed project templates: disabled Nuxt2.js entries, enabled Nuxt3.js as default Nuxt template.
- Added React project template support.

### Fixed
- Fixed Java version discovery: `CB_DEVTOOLS_JAVA_PREFIX` changed from `*jdk*` to `*jdk-` for more specific matching.
- Added missing `return` statement in custom config execution.

## [1.0.1] - 2024-01-08
### Changed
- Updated Gradle default version from 8.1.1 to 8.5.

### Fixed
- Fixed Gradle version configuration.

## [1.0.0] - 2024-01-08
### Changed
- Major release v1.0.0.
- Updated tool versions.

## [0.9.46] - 2023-12-12
### Added
- RangerDesktop support (`bin/packages/rangerdesktop/rangerdesktop.bat`).

### Changed
- Major tool version updates across all packages:
  - Java: 11 to **21**
  - Gradle: 7.3.1 to 8.1.1
  - Eclipse: 2021-12 to 2023-12
  - Node: 16.13.2 to 18.14.2 (later to 20.10.0)
  - Python: 3.10.2 to 3.12.1
  - VSCode: 1.62.0 to 1.85.0
  - Git: 2.28.0 to 2.43.0
  - Flutter: 2.5.3 to 3.16.3
  - Groovy: 3.0.8 to 4.0.16
  - IntelliJ: 2021.2 to 2023.3
  - Maven: 3.6.3 to 3.9.6
  - Micronaut: 3.1.4 to 4.2.1
  - and others (Ant, BTrace, JMeter, SBT, Squirrel, VisualVM, WinMerge)

## [0.9.45] - 2023-12-12
### Fixed
- Improved error handling for Eclipse downloads.

## [0.9.44] - 2023-04-25
### Changed
- Updated IntelliJ IDEA installation script for better compatibility.

## [0.9.43] - 2023-04-25
### Changed
- Refactored IntelliJ installation script.
- Updated tool versions.

## [0.9.42] - 2023-02-23
### Changed
- Updated license headers across all package scripts to GNU GPL v3 format.
- Updated tool versions across the board.

## [0.9.41] - 2023-02-23
### Fixed
- Refactored Eclipse installation script with better error handling for downloads.

## [0.9.40] - 2023-02-16
### Changed
- Finalized multiple homes support (version bump).

## [0.9.39] - 2023-02-16
### Fixed
- Custom config script bugfix.

## [0.9.38] - 2023-02-16
### Added
- Support for multiple common org config entries on the same system, allowing different custom configs per git project.

## [0.9.37] - 2022-12-21
### Fixed
- Fixed Windows timestamp issue in `cb.bat` date formatting.

## [0.9.36] - 2022-12-21
### Fixed
- Fixed Windows timestamp generation for custom config date checks.

## [0.9.35] - 2022-12-21
### Fixed
- Fixed timestamp comparison issue in custom config update check.

## [0.9.34] - 2022-12-20
### Fixed
- Fixed time conversion issue in `cb.bat` affecting daily update check.

## [0.9.33] - 2022-12-19
### Fixed
- Fixed `GET_TIMESTAMP` function in `cb.bat` with enhanced environment handling.

## [0.9.32] - 2022-12-19
### Fixed
- Fixed lock-unlock mechanism for consistent concurrent access behavior.

## [0.9.31] - 2022-12-12
### Changed
- Improved `cb.bat` performance for Windows path handling.

## [0.9.30] - 2022-12-09
### Added
- Support for multiple common org config with lock/unlock mechanism (`bin/include/lock-unlock.bat/sh` significantly enhanced).
- Performance optimizations in `cb` and `cb.bat`.

### Changed
- Updated Gradle from 7.3 to 7.3.1, Node from 16.13.0 to 16.13.2.
### Changed
### Fixed
- Fixed Docker URL in package configuration.

## [0.9.28] - 2022-10-28
### Fixed
- Fixed Nuxt project generation to force create instead of failing silently.

## [0.9.27] - 2022-10-28
### Changed
- Refactored `cb-json` for improved JSON parsing.

### Fixed
- Fixed Nuxt project generator and jq support.

## [0.9.26] - 2022-02-27
### Changed
- Updated Eclipse and tool versions.

## [0.9.25] - 2022-02-03
### Fixed
- Python package script fix.

## [0.9.24] - 2022-02-03
### Added
- Python support (`bin/packages/python/python.bat` and `python.sh`). Default version: 3.10.2.
- Added Python to PATH configuration in `cb` and `cb.bat`.
- Updated sample scripts for Python projects.

## [0.9.23] - 2022-01-11
### Changed
- Optimized Gradle wrapper execution rights handling.

## [0.9.22] - 2022-01-09
### Added
- Support for `CB_BUILD_UPDATE` flag to control build update behavior.

## [0.9.21] - 2022-01-05
### Added
- Support for verify configuration (`ENABLE_CONFIGURATION` flag).
- Enhanced `cb` and `cb.bat` with new build/environment flags.
- Added sample script templates for custom configurations.

### Changed
- Updated `tool-version-default.properties`.

## [0.9.20] - 2021-11-30
### Changed
- Reverted git upgrade due to compatibility issues.
- Updated Gradle from 7.2.0 to 7.3.

## [0.9.19] - 2021-11-30
### Changed
- Credential handling improvements in `cb-credential.bat`.

## [0.9.18] - 2021-11-14
### Added
- Rust support (`bin/packages/rust/rust.bat` and `rust.sh`).
- JRE support (`bin/packages/jre/jre.bat` and `jre.sh`) - Java Runtime Environment separate from JDK.
- Improved Java version detection with separate handling for JDK vs JRE.

### Changed
- Updated Gradle from 7.1.1 to 7.2.0.

### Fixed
- Fixed license link.

## [0.9.17] - 2021-07-28
### Changed
- Updated tool versions.
- Fixed credential script for better environment variable handling.

## [0.9.16] - 2021-04-22
### Added
- IntelliJ IDEA support (`bin/packages/intellij/intellij.bat` and `intellij.sh`).
- WinMerge support (`bin/packages/winmerge/winmerge.bat`).
- Added `bin/include/hashCode.sh` utility.

### Changed
- Major tool version updates:
  - Flutter: 1.22.2 to 2.2.3
  - Gradle: 6.6 to 7.1.1
  - Node: 12.19.0 to 14.17.3
  - Git: 2.28.0 to 2.32.0
  - IntelliJ: 2021.2 (new)
  - VSCode: 1.58.0 (new)

## [0.9.15] - 2021-03-29
### Fixed
- Adapted `CB_DEVTOOLS_JAVA_PREFIX` pattern for JDK 8 compatibility.
- Fixed `set errorlevel` handling in batch scripts.
- Credential handling improvements for shell scripts.

## [0.9.14] - 2021-02-16
### Added
- Support for `@@delete@@` placeholder in project template processing.

### Changed
- Changed software license from MIT to GNU GPL v3 (updated all source files with GPL header).

## [0.9.12] - 2021-02-14
### Changed
- Updated tool versions: Flutter 1.22.2 to 2.0.1, Gradle 6.6 to 6.7.1.
- Updated `project-types.properties` configuration.

### Fixed
- Fixed install and top directory detection issue.
- Fixed project wizard dependency handling.

## [0.9.11] - 2021-02-13
### Fixed
- Fixed handling of missing `xz` utils during installation (graceful fallback).

## [0.9.10] - 2021-01-14
### Added
- Scoop package manager support (`bin/packages/scoop/scoop.bat`).
- GRGIT support for Git operations.
- Local git project support.
- Enhanced credential handling with profile support.
- Shell script utilities for downloading.

### Fixed
- Fixed sample scripts.

## [0.9.9] - 2021-01-10
### Fixed
- Fixed WSL2 compatibility issues.

## [0.9.8] - 2021-01-10
### Changed
- Optimized project wizard.
- Support for product-individual project configuration.

## [0.9.7] - 2021-01-04
### Added
- Sample custom configuration templates (`cb-custom-sample.bat/sh` and `cb-custom.bat/sh`).
- Devtools initialisation support for shell.

### Changed
- Improved WSL support.
- Enhanced credential handling.

### Fixed
- Fixed fish shell compatibility.

## [0.9.6] - 2020-12-30
### Added
- Fish shell support.

### Fixed
- Fixed Linux and Node.js project handling.
- Fixed temp folder handling on Linux.

## [0.9.5] - 2020-12-13
### Added
- Added `cb-install-check.bat` and `cb-install-check.sh` - pre-flight validation scripts for installations.

## [0.9.4] - 2020-12-12
### Fixed
- Fixed project wizard issues.
- Disabled jq due to compatibility issues.

## [0.9.3] - 2020-12-11
### Changed
- Force common gradle build update when available during an update operation.

### Fixed
- Fixed download error handling.

## [0.9.2] - 2020-11-17
### Fixed
- Fixed project-wizard batch script.

## [0.9.1] - 2020-11-15
### Added
- Added `--update` command to manually trigger custom config update.

## [0.9.0] - 2020-11-07
### Changed
- Improved temp path handling.

## [0.8.20] - 2020-11-02
### Fixed
- Fixed PATH not being set correctly.
- Fixed Linux custom config information display.

## [0.8.19] - 2020-11-01
### Added
- Git installation documentation (`bin/packages/git/git-install.txt`).

### Fixed
- Fixed `@@logFile@@` placeholder handling in `project-types.properties`.
- Fixed Node.js project support on Linux.

## [0.8.18] - 2020-10-30
### Added
- `jq` tool support in `cb-json` with fallback to grep/awk.
- gawk detection with awk compatibility handling (gawk vs mawk).

### Changed
- Updated Ant from 1.10.8 to 1.10.9, Flutter from 1.20.2 to 1.22.2.

### Fixed
- Fixed Alpine / Busybox support (improved zip extraction with better `awk` patterns).

## [0.8.17] - 2020-10-09
### Changed
- Improved Linux environment handling and logging.

## [0.8.16] - 2020-10-05
### Changed
- Improved WSL support under Windows.

### Fixed
- Fixed unzip check logic.

## [0.8.15] - 2020-09-24
### Fixed
- Credential handling fixes for Linux/Mac compatibility.

## [0.8.14] - 2020-09-22
### Changed
- Optimized project wizard.

## [0.8.12] - 2020-09-21
### Fixed
- Fixed multiple issues with home directories containing spaces (both Linux and Windows).
- Fixed tar archive naming.

## [0.8.11] - 2020-09-20
### Changed
- Enhanced offline support with better logging when custom config updates fail.

### Fixed
- Fixed common-build-home configuration project support under Linux.

## [0.8.10] - 2020-09-16
### Fixed
- Fixed offline handling for custom config updates.
- Fixed cb fails when `JAVA_HOME` path contains spaces.
- Fixed "Could not create SSL/TLS secure channel" error on Windows.

## [0.8.9] - 2020-09-10
### Fixed
- Custom configuration update improvements.

## [0.8.8] - 2020-09-09
### Added
- New custom event `custom-config-update-end` hook called after custom config updates complete.

### Changed
- Simplified project wizard logic.

## [0.8.7] - 2020-09-07
### Added
- Atom text editor package (`bin/packages/atom/`).
- Visual Studio Code package (`bin/packages/vscode/`).
- OpenAPI project type support in `project-types.properties`.

### Changed
- Simplified project wizard.

## [0.8.6] - 2020-09-02
### Added
- JD Decompiler package (`bin/packages/jd/`).

### Changed
- Enhanced project wizard.

## [0.8.5] - 2020-08-31
### Fixed
- Fixed Windows PATH handling for users with spaces in username.

## [0.8.4] - 2020-08-31
### Fixed
- Minor deltree improvements.

## [0.8.3] - 2020-08-31
### Added
- Support for `tool-version-default.properties` override from `CB_CUSTOM_CONFIG`.
- Thread-safe locking mechanism (`bin/include/lock-unlock.bat` and `.sh`).
- Version detection utilities (`bin/include/read-version.bat` and `.sh`).
- Custom configuration management (`bin/include/update-cb-custom-home.bat` and `.sh`).

### Changed
- Major refactoring of credential and custom configuration handling.
- Improved `CB_CUSTOM_CONFIG` update mechanism.
- Improved version parsing and tracking in custom configurations.

### Removed
- Removed `init-home.bat` and `.sh` (functionality moved to lock-unlock and update-cb-custom-home).

## [0.8.2] - 2020-08-29
### Changed
- Optimized update process and `cb-deltree` batch file.

## [0.8.1] - 2020-08-29
### Added
- Windows shortcut creation support (`bin/cb-shortcut.bat`).
- JMeter icon (`bin/packages/jmeter/jmeter.ico`).
- Windows Terminal icon (`bin/packages/wt/wt.ico`).

### Fixed
- Fixed username with spaces and MultiCommander open support.

## [0.8.0] - 2020-08-24
### Added
- Docker support (`bin/packages/docker/`) with automated installation.
- Credential management system (`bin/include/cb-credential.bat` and `.sh`).
- Home initialization (`bin/include/init-home.bat` and `.sh`).
- Multi-Commander package (`bin/packages/multicommander/`).
- Notepad++ package (`bin/packages/npp/`).
- Support for `.cb-custom-config` file for custom configuration references.
- `CB_PACKAGE_INSTALL_PARAMETER`, `CB_PACKAGE_NO_DEFAULT`, and `CB_PACKAGE_ALREADY_EXIST` flags.
- Node and Gradle build support.
- Product types configuration (`conf/product-types-sample.properties`).
- Docker terminal types (`conf/dockterm-types.properties`).
- Logo assets (PNG and SVG).
- Abort project creation when already inside a project.

### Changed
- Major architectural refactoring: separated credential/environment initialization from build execution.
- Enhanced project creation wizard.
- Refactored custom events.

## [0.7.12] - 2020-08-03
### Added
- GitHub Actions workflow (`.github/workflows/blank.yml`).

### Changed
- Compatibility improvements for build operations.

## [0.7.11] - 2020-08-02
### Changed
- Skip build when no build configuration is present (graceful exit).
- Code cleanup.

## [0.7.10] - 2020-08-02
### Added
- Comprehensive test data files for tool discovery (`testdata/adoptopenjdk.json`, `testdata/github.json`, `testdata/eclipse.json`).
- `bin/cb-deltree.bat` for Windows directory cleanup.

### Changed
- Windows cleanup improvements.
- BSD compliance improvements.

## [0.7.9] - 2020-08-02
### Changed
- Improved interoperability across platforms.
- Enhanced online check and executable compliance detection.

### Fixed
- Fixed error handling for missing packages.
- Fixed cb-custom-sample and project-types configuration.

## [0.7.8] - 2020-08-01
### Added
- How-to documentation scripts (`bin/include/how-to.bat` and `how-to.sh`) shown after installation and via `--help`.

### Changed
- Refactored build and install logic with better error handling.

## [0.7.7] - 2020-07-31
### Fixed
- Linux compatibility fixes.

## [0.7.6] - 2020-07-31
### Fixed
- Cross-platform interoperability fixes.

## [0.7.5] - 2020-07-30
### Changed
- Linux / macOS compatibility improvements.
- Improved `cb-json` parser reliability.
- Enhanced installer robustness.

## [0.7.4] - 2020-07-29
### Changed
- Eclipse IDE version configuration.
- Minor PATH handling improvements.

## [0.7.3] - 2020-07-29
### Added
- Eclipse IDE package (`bin/packages/eclipse/`).
- `cb-json` tool for JSON parsing in configuration handling.
- Windows Terminal package (`bin/packages/wt/`).
- `--verbose` flag support.
- Additional project templates in `project-types.properties`.

### Changed
- Completely reimplemented project creation wizard.
- Enhanced all package shell scripts to use consistent TOPDIR patterns.

## [0.7.2] - 2020-07-25
### Changed
- Major refactoring of build logic in `cb` and installer scripts.

## [0.7.1] - 2020-07-25
### Added
- Node.js support with proper symlink copying.
- Shell support improvements.

### Fixed
- Fixed file size handling.

## [0.7.0] - 2020-07-23
### Added
- Centralized tool version management via `conf/tool-version-default.properties` (ant, btrace, flutter, gradle, groovy, java, jmeter, maven, micronaut, node, sbt, squirrel, visualvm, docker, git, postman, insomnia).
- `bin/cb-copysymlink.bat` for Windows symlink handling.
- Insomnia API client package.
- `.gitattributes` for line ending management.

### Changed
- Default version support for all packages.

### Removed
- Removed Selenium IDE and SoapUI packages.

## [0.6.2] - 2020-07-19
### Fixed
- Fixed environment handling.

## [0.6.1] - 2020-07-19
### Changed
- Installation improvements.

## [0.6.0] - 2020-07-19
### Added
- Project types configuration (`conf/project-types.properties`) for project-specific build settings.
- `bin/cb-cleanpath.bat` for Windows PATH cleanup.

### Changed
- Enhanced project wizard with project type support.

## [0.5.6] - 2020-07-17
### Added
- 13 new tool packages: BTrace, Flutter, Gaiden, Groovy, JMeter, Micronaut, Postman, SBT, Selenium IDE, SoapUI, Squirrel, VisualVM, and more.
- Corresponding `.bat` and `.sh` installer files for each tool.

## [0.5.5] - 2020-07-15
### Fixed
- Docker package configuration adjustments.

## [0.5.4] - 2020-07-15
### Fixed
- Minor version and configuration fixes.

## [0.5.3] - 2020-07-15
### Added
- Custom script support (`cb-custom-sample`).
- Unzip support for package extraction.
- Enhanced Node.js and Gradle package support.

### Fixed
- Fixed project wizard.
- Fixed Linux environment handling.
- Fixed Windows version detection.

## [0.5.2] - 2020-07-10
### Fixed
- Fixed handling of multiple git tags during version detection.

## [0.5.1] - 2020-07-10
### Added
- First Linux version of the main `cb` script.
- Enhanced Java package with Linux support.

### Changed
- Improved tempfile handling.
- Prevent duplicate PATH entries.
- Updated console output formatting.

## [0.5.0] - 2020-07-02
### Added
- Project wizard for creating new projects (`bin/include/project-wizard.bat` and `.sh`).
- `cb-install` and `cb-install.bat` official installers.
- Cygwin compatibility.
- Linux/Mac shell script support.
- `bin/include/download.bat` for tool downloads.

### Changed
- Major restructuring: moved scripts from `src/main/cli/` to `bin/` directory.
- Package modularisation: created `bin/packages/` structure with individual tool installers (ant, gradle, java, maven, node, git, docker, cb, etc.).
- Refactored variable names for consistency.

### Fixed
- Fixed GitHub v3 API usage for AdoptOpenJDK downloads.
- Fixed version number reading.
- Fixed cb-install issues.

## [0.4.0] - 2020-06-25
### Added
- Initial release.
- Maven wrapper support.
- Version management support.
- Multiple JDK version support.
- Environment variable configuration.
- Basic documentation.

### Fixed
- Fixed handling of user names with spaces.
- Fixed working path resolution.
- Fixed installation flow.
