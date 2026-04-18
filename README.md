# common-build
[![License](https://img.shields.io/github/license/toolarium/common-build)](https://opensource.org/licenses/GPL-3.0)
[![CI](https://github.com/toolarium/common-build/actions/workflows/cb-test.yml/badge.svg)](https://github.com/toolarium/common-build/actions/workflows/cb-test.yml)
[![Release](https://img.shields.io/github/v/release/toolarium/common-build)](https://github.com/toolarium/common-build/releases/latest)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macOS%20%7C%20windows-blue)]()

<img align="right" height="110" src="docs/logo/common-build-icon.png">

The common-build project simplifies the development environment setup across Linux, MacOS and Windows.
It acts as a transparent wrapper for common build tools such as Gradle, Maven or Ant, and manages the installation of developer tools like Java, Node, Python, Trivy and many more. All software is installed into a local "devtools" directory, and all settings can be overridden via environment variables.
No administrator or root privileges are required.

Key features:

- **Tool management** — Install, update and switch between versions of developer tools with a single command (`cb --install`). Use `cb --setenv` to add all managed tools to your PATH.
- **Build execution** — Run project builds transparently through Gradle, Maven or Ant without manual setup.
- **[Project wizard](docs/project-wizard.md)** — Scaffold new projects interactively with `cb --new`, supporting multiple project types (Java, Node/React/Vue/Nuxt, Kubernetes, OpenAPI, and more).
- **[Organization Config](docs/organization-config.md)** — Centralize tool versions, project templates, naming conventions and lifecycle hooks in a Git repository for consistent corporate-wide developer environments.
- **[Package development](docs/package-development.html)** — Add new tool packages to common-build with a simple script convention, supporting cross-platform downloads, version management, and post-install hooks.
- **Self-update** — Keep common-build itself up to date with `cb --install cb`.
- **[Automated testing](docs/testing.md)** — Cross-platform test suite with sandbox isolation, gated build verification, and nightly CI coverage for all project types.

> Works hand in hand with its sister project [**common-gradle-build**](https://github.com/toolarium/common-gradle-build). For Gradle-based projects, common-gradle-build provides the build framework while common-build manages the developer toolchain and project scaffolding.


## Installing common-build

### Using script to install the latest release

**Linux / MacOS**

Install the latest cli to `$HOME/devtools`:

```bash
curl -fsSL https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install | /bin/bash
```

Alternatively, download [`cb-install`](https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install) manually and run it with `/bin/bash cb-install`.

Tested on debian, ubuntu, centos, fedora and macOS.

**Windows**

Install the latest cli to `c:\devtools` and add this directory to the User PATH environment variable:

```powershell
powershell -Command "iwr https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install.bat -OutFile ${env:TEMP}/cb-install.bat" & %TEMP%\cb-install.bat
```

Alternatively, download [`cb-install.bat`](https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install.bat) manually and run it.

The common-build also supports cygwin — use the Linux installation for that.
Currently only Windows 10 is properly tested.


## Usage

```
cb [OPTION] [build-arguments...]
```

When called without options (or with build arguments only), `cb` sets up the required tools and executes the project build (Gradle, Maven, or Ant) found in the current directory.


## Options

| Option | Description |
|---|---|
| `-h`, `--help` | Show the help message. |
| `-v`, `--version` | Print version information and installed tool versions. |
| `--new` | Create a new project via an interactive [project wizard](docs/project-wizard.md). Settings can be prefilled, e.g. `--new 1 my-project my.root.pkg my my`. |
| `--java [version]` | Override the Java version for this run, e.g. `--java 17`. |
| `--install [pkg] [version]` | Install a software package. Uses the default version from `tool-version-default.properties` unless a version is specified. Add `-d` or `--default` to mark the installed version as the default. See [Package Development](docs/package-development.html) for creating custom packages. |
| `--packages` | List all supported packages. |
| `--setenv` | Set all internal environment variables (adds installed tools to `PATH`). This is the recommended way to make all managed tools available on the command line. It adds tools like git, node, java, maven, gradle, python, trivy, ant and others to the current `PATH`. For GraalVM, only `GRAALVM_HOME` is set (not added to `PATH`). On Windows, if Visual Studio Build Tools are installed, the VC environment is initialized automatically via `vcvars64.bat`. |
| `--nushell` | When used with `--setenv`, output [Nushell](https://www.nushell.sh/)-compatible syntax (`$env.VAR = '...'`) instead of modifying the current shell. See [Nushell support](#nushell-support) below. |
| `--update` | Update the custom config. Can be combined with `--force`. |
| `-exp`, `--explore` | Open the file explorer at the current path. |
| `--silent` | Suppress console output from common-build. |
| `--force` | Force a fresh installation (re-download and re-extract). |
| `--offline` | Use offline mode (normally auto-detected). |
| `--verbose` | Enable verbose output. |
| `--default` | Mark an installed package version as the default. |


## Supported Packages

The following packages can be installed via `cb --install <package>`:

| Package | Default Version | Description |
|---|---|---|
| [ant](https://ant.apache.org/) | 1.10.15 | Apache Ant build tool |
| [btrace](https://github.com/btraceio/btrace) | 2.2.6 | BTrace dynamic tracing tool |
| [docker](https://www.docker.com/) | | Docker |
| [eclipse](https://www.eclipse.org/) | 2026-03 | Eclipse IDE (JEE package) |
| [flutter](https://flutter.dev/) | 3.41.5 | Flutter SDK |
| [gaiden](https://github.com/kobo/gaiden) | 1.3 | Gaiden documentation tool |
| [gradle](https://gradle.org/) | 8.13 | Gradle build tool |
| [groovy](https://groovy-lang.org/) | 4.0.31 | Apache Groovy |
| [insomnia](https://insomnia.rest/) | | Insomnia API client |
| [intellij](https://www.jetbrains.com/idea/) | 2025.2.6.1 | IntelliJ IDEA |
| [graalvm](https://www.graalvm.org/) | 21.0.2 | GraalVM Community Edition |
| [java](https://adoptium.net/) | 21 | Java JDK |
| [jmeter](https://jmeter.apache.org/) | 5.6.3 | Apache JMeter |
| [maven](https://maven.apache.org/) | 3.9.14 | Apache Maven |
| [micronaut](https://micronaut.io/) | 4.10.18 | Micronaut framework CLI |
| [mucommander](https://www.mucommander.com/) | 1.6.0-1 | muCommander file manager |
| [node](https://nodejs.org/) | 24.14.1 | Node.js |
| [postman](https://www.postman.com/) | | Postman API client |
| [python](https://www.python.org/) | 3.13.12 | Python |
| [rust](https://www.rust-lang.org/) | | Rust toolchain |
| [sbt](https://www.scala-sbt.org/) | 1.12.8 | Scala Build Tool |
| [squirrel](https://squirrel-sql.sourceforge.io/) | 5.1.0 | SQuirreL SQL Client |
| [trivy](https://trivy.dev/) | 0.69.3 | Trivy security scanner |
| [visualvm](https://visualvm.github.io/) | 2.2.1 | VisualVM profiler |
| [vscode](https://code.visualstudio.com/) | 1.113.0 | Visual Studio Code |

Windows-only packages: [`git`](https://git-scm.com/), [`npp`](https://notepad-plus-plus.org/) (Notepad++), [`multicommander`](https://multicommander.com/), [`winmerge`](https://winmerge.org/), [`wt`](https://github.com/microsoft/terminal) (Windows Terminal), [`scoop`](https://scoop.sh/), [`rangerdesktop`](https://rancherdesktop.io/).


## Utility Scripts

In addition to the main `cb` command, common-build ships with a set of standalone helper scripts in `bin/`. Each one has cross-platform counterparts (shell script and `.bat`) and supports `-h` / `--help`.

| Script | Description |
|---|---|
| `cb-clean-files` | Delete regular files older than N days from a single directory (top-level, non-recursive). Supports glob pattern filter, `--dry-run` and `--silent` modes. Rejects dangerous target paths (`/`, `$HOME`, `/usr`, `/etc`, ...). |
| `cb-cleanup` | Cleanup common-build artifacts (caches, temp directories, stale downloads). Calls `cleanup-start` / `cleanup-end` lifecycle hooks if a custom hook script is configured. |
| `cb-dockterm` | Open an interactive terminal inside a running Docker container. Types are defined in `conf/dockterm-types.properties` (key = type name, value = Docker image). Default types: alpine, arch, debian, fedora, kali, ubuntu. Add custom entries to use private or corporate images. |
| `cb-filetail` | Follow/tail a file (like `tail -f`) with optional `grep` filtering — cross-platform, works on Windows too. |
| `cb-meminfo` | Print memory usage information for the current host. |
| `cb-open-ports` | List all open TCP/UDP ports on the host. Accepts optional filter arguments (e.g. `cb-open-ports 8080 443`). |
| `cb-shortcut` | Create Windows desktop shortcuts (Windows-only). |
| `cb-version-filter` | Filter a list of semver version numbers by major-version thresholds and previous-major patch thresholds. Accepts input via stdin, file, or `--path`. Useful for pruning old release versions. Example: `echo 2.2.1 2.1.0 1.3.4 1.2.0 \| cb-version-filter --majorThreshold 2 --previousMajorPatchThreshold 2` |


## Examples

Run a build:
```bash
cb
```

Run a build with a specific Java version:
```bash
cb --java 17
```

Install a package:
```bash
cb --install gradle
```

Install a specific version and set it as default:
```bash
cb --install gradle 8.12 --default
```

Set up environment (recommended — add all managed tools to PATH):
```batch
:: Windows:
cb --setenv
```
```bash
# Linux/Mac:
. cb --setenv
# or
source cb --setenv
```
```nu
# Nushell (save output to a file, then source it):
cb --setenv --nushell | save -f ~/.config/nushell/cb-tools.nu
source ~/.config/nushell/cb-tools.nu
```

This makes tools like java, gradle, maven, node, python, git, trivy, ant, etc. directly available on the command line. GraalVM is not added to `PATH` but `GRAALVM_HOME` is set.

List available packages:
```bash
cb --packages
```

Create a new project:
```bash
cb --new
```

Update common-build itself to the latest version:
```bash
cb --install cb
```


## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `CB_DEVTOOLS` | Root directory for all dev tools. | `$HOME/devtools` (Linux/macOS), `c:\devtools` (Windows) |
| `CB_DEVTOOLS_NAME` | Name of the devtools directory (without path). | `devtools` |
| `CB_DEVTOOLS_DRIVE` | (Windows only) Drive letter where devtools are installed. | `c:` |
| `CB_HOME` | Common-build installation directory. | `$CB_DEVTOOLS/toolarium-common-build-v<version>` |
| `CB_TEMP` | Temporary directory for work files, download caches, and lock files. | `$TMPDIR/cb-$USER` (Unix), `%TEMP%\cb` (Windows) |
| `CB_CUSTOM_CONFIG` | Git URL to a custom config project for full customization. | |
| `CB_CUSTOM_SETTING` | Path to a custom hook script called during all operations. See [`docs/sample/`](docs/sample/) for templates. | |
| `CB_PACKAGE_URL` | URL to a directory of additional package zip files. | |
| `CB_PACKAGE_USER` | Username for accessing `CB_PACKAGE_URL`. | |
| `CB_PACKAGE_PASSWORD` | Password for `CB_PACKAGE_URL`. Set to `ask` for interactive prompt. | |
| `CB_ONLINE_ADDRESS` | IP address or hostname for the internet connectivity check. Override for corporate proxies. | `8.8.8.8` |
| `CB_ONLINE_ADDRESS_PORT` | Port for the connectivity check. | `53` |
| `CB_ONLINE_TIMEOUT` | Timeout in seconds for the connectivity check. | `2` |
| `CB_INSTALL_ONLY_STABLE` | Set to `false` to allow pre-release/draft versions during `cb-install`. | `true` |


## Tool Version Defaults

The file `conf/tool-version-default.properties` defines the default version for every managed tool. When you run `cb --install <package>` without specifying a version, the version from this file is used. It is a simple `key = value` format:

```properties
java = 21
graalvm = 21.0.2
gradle = 8.13
node = 24.14.1
```

You can override a tool version per-run (e.g. `cb --java 17`) or install a specific version and mark it as the new default with `cb --install gradle 8.12 --default`. Installed versions are tracked in `conf/tool-version-installed.properties`.


## Product Types

A **product type** is an organizational grouping that pre-fills wizard defaults when creating new projects. Products are defined in `conf/product-types.properties` (see `conf/product-types-sample.properties` for a template).

Each product maps a name to a set of key:value pairs separated by `|`:

```properties
My product = projectComponentId:myc|projectGroupId:myg|projectRootPackageName:myc.rootpackage.name
```

When a user selects a product during `cb --new`, the configured values are automatically applied as defaults for the project wizard fields (component ID, group ID, root package name, etc.). This avoids repetitive input when creating multiple projects under the same product umbrella.

Product types are optional. If no `product-types.properties` file exists, the wizard skips the product selection step.


## Project Types

A **project type** is a template that defines what kind of project to scaffold and which wizard fields to prompt. Project types are defined in `conf/project-types.properties`.

Each entry maps a type ID to a description and a list of configuration sections:

```properties
java-application = Simple java application|projectName|projectRootPackageName|projectGroupId|projectComponentId|projectDescription
vuejs = Vue|projectName=-ui|projectComponentId|projectDescription|install=node|initAction=npx --yes @vue/cli create --default @@projectName@@ >@@logFile@@
```

Available project types include: `java-application`, `java-library`, `config`, `script`, `openapi`, `quarkus`, `vuejs`, `nuxtjs`, `react`, `kubernetes-product`, `documentation`, `container`, and `organization-config`.

For full details on how project types work and how to configure them, see the [Project Wizard documentation](docs/project-wizard.md).


## Per-Project Java Version

Place a `.java-version` file in your project root containing just the major version number:

```
17
```

When `cb` runs in that directory, it automatically switches to the specified Java version. This is useful for teams working on projects with different Java requirements — each project controls its own version without affecting others.


## How It Works

When you run `cb` in a project directory, the following happens:

```
cb [build-arguments...]
 │
 ├─ 1. Load configuration
 │     Read tool-version-default.properties, custom config, .java-version
 │
 ├─ 2. Set up tools
 │     Resolve and add Java, Gradle/Maven/Ant, and other tools to PATH
 │
 ├─ 3. Run lifecycle hooks
 │     Call custom hook script (if configured): verify-configuration, build-start
 │
 ├─ 4. Execute build
 │     Detect build system (build.gradle → Gradle, pom.xml → Maven, build.xml → Ant)
 │     Run the build with all arguments forwarded
 │
 └─ 5. Post-build
       Call build-end hook (if configured)
```

For `cb --setenv`, only steps 1-2 are executed to set up tools in the current shell.
For `cb --install <package>`, the tool is downloaded, extracted and linked into the `current/` directory.
For `cb --new`, the [project wizard](docs/project-wizard.md) is started instead.


## Sample Output of `cb --version`

```
================================================================================
toolarium common build 1.0.14

.: Installed tool versions:
    - ant: 1.10.15
    - gradle: 8.13
    - java: 21
    - maven: 3.9.14
    - node: 24.14.1
    - python: 3.13.12
    - trivy: 0.69.3
================================================================================
```


## Special Files

| File | Description |
|---|---|
| `.java-version` | Place in a project root to pin a specific Java version (e.g. `17`). |
| `conf/tool-version-default.properties` | Default versions for all tools. |
| `conf/tool-version-installed.properties` | Tracks currently installed tool versions. |
| `conf/project-types.properties` | Project type definitions for `cb --new`. |
| `conf/product-types.properties` | Product type definitions (optional). |
| `conf/dockterm-types.properties` | Docker container types for `cb-dockterm`. Key = type name, value = Docker image. |


## Customization

### Custom Hook Script

Set `CB_CUSTOM_SETTING` to point to a shell script that will be called at various lifecycle hooks: `start`, `build-start`, `build-end`, `install-start`, `install-end`, `cleanup-start`, `cleanup-end`, `setenv-start`, `setenv-end`, `error-end`, and more. See the [sample scripts](docs/sample/) for complete templates:

- [`cb-custom-sample.sh`](docs/sample/cb-custom-sample.sh) / [`cb-custom-sample.bat`](docs/sample/cb-custom-sample.bat) — fully commented samples with all hooks active
- [`cb-custom.sh`](docs/sample/cb-custom.sh) / [`cb-custom.bat`](docs/sample/cb-custom.bat) — minimal templates ready to copy and customize

### Custom Config Project

For organization-wide customization, create a Custom Config Home project (`cb --new`, select the organization-config template). Publish it as a git repository and set `CB_CUSTOM_CONFIG` to the git URL. Common-build checks for updates daily and applies the configuration automatically.

Alternatively, add the git URL to the file `$HOME/.common-build/conf/.cb-custom-config`.

For full details on setting up an organization config with custom tool versions, project types, product types, lifecycle hooks, and concrete examples, see the [Organization Config documentation](docs/organization-config.md).


## Nushell Support

Common-build supports [Nushell](https://www.nushell.sh/) as a first-class shell. The `--nushell` flag causes `cb --setenv` to output Nushell-compatible environment variable assignments instead of modifying the current process environment.

**Manual usage:**

```nu
# Print Nushell env commands to stdout
cb --setenv --nushell

# Save and source in one step
cb --setenv --nushell | save -f ~/.config/nushell/cb-tools.nu
source ~/.config/nushell/cb-tools.nu
```

**Automatic setup via installer:**

When `cb-install` (or `cb-install.bat`) detects that Nushell is installed, it automatically:
1. Creates `~/.config/nushell/cb-setenv.nu` with `CB_HOME` and `PATH` configuration.
2. Adds a `source` line to `~/.config/nushell/env.nu` so the configuration is loaded on every Nushell startup.

On subsequent updates (`cb --install cb`), the `cb-setenv.nu` file is regenerated with the updated `CB_HOME` path.


## Versioning and compatibility

This project follows [Semantic Versioning](https://semver.org/):

- **Patch** releases (e.g. 1.0.1 → 1.0.2) are fully backward compatible — bug fixes only.
- **Minor** releases (e.g. 1.0.x → 1.1.0) add new features while remaining backward compatible — all existing scripts, environment variables, and configurations continue to work.
- **Major** releases (e.g. 1.x → 2.0.0) may introduce breaking changes.

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed compatibility guidelines.

