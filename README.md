# common-build 
[![License](https://img.shields.io/github/license/toolarium/common-build)](https://opensource.org/licenses/GPL-3.0)

<img align="right" height="110" src="docs/logo/common-build-icon.png">

The common-build project simplifies the development environment setup across Linux, MacOS and Windows.
It acts as a transparent wrapper for common build tools such as Gradle, Maven or Ant, and manages the installation of developer tools like Java, Node, Python, Trivy and many more. All software is installed into a local "devtools" directory, and all settings can be overridden via environment variables.

Key features:

- **Tool management** — Install, update and switch between versions of developer tools with a single command (`cb --install`). Use `cb --setenv` to add all managed tools to your PATH.
- **Build execution** — Run project builds transparently through Gradle, Maven or Ant without manual setup.
- **[Project wizard](docs/project-wizard.md)** — Scaffold new projects interactively with `cb --new`, supporting multiple project types (Java, Node/React/Vue/Nuxt, Kubernetes, OpenAPI, and more).
- **[Organization config](docs/organization-config.md)** — Centralize tool versions, project templates, naming conventions and lifecycle hooks in a Git repository for consistent corporate-wide developer environments.
- **Self-update** — Keep common-build itself up to date with `cb --install cb`.


## Installing common-build

### Using script to install the latest release

**Linux / MacOS**

Install the latest cli to `$HOME/devtools`:

```bash
curl -fsSL https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install | /bin/bash
```

Alternatively, download [`cb-install`](https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install) manually and run it with `/bin/bash cb-install`.

Tested on debian, ubuntu, centos and fedora. MacOS is not yet fully tested.

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
| `--new` | Create a new project via an interactive wizard. Settings can be prefilled, e.g. `--new 1 my-project my.root.pkg my my`. |
| `--java [version]` | Override the Java version for this run, e.g. `--java 17`. |
| `--install [pkg] [version]` | Install a software package. Uses the default version from `tool-version-default.properties` unless a version is specified. Add `-d` or `--default` to mark the installed version as the default. |
| `--packages` | List all supported packages. |
| `--setenv` | Set all internal environment variables (adds installed tools to `PATH`). This is the recommended way to make all managed tools available on the command line. It adds tools like git, node, java, maven, gradle, python, trivy, ant and others to the current `PATH`. |
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

This makes tools like java, gradle, maven, node, python, git, trivy, ant, etc. directly available on the command line.

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
| `CB_HOME` | Common-build installation directory. | `$CB_DEVTOOLS/toolarium-common-build-v<version>` |
| `CB_CUSTOM_CONFIG` | Git URL to a custom config project for full customization. | |
| `CB_CUSTOM_SETTING` | Path to a custom hook script called during all operations. See `$CB_HOME/bin/sample/cb-custom-sample.sh`. | |
| `CB_PACKAGE_URL` | URL to a directory of additional package zip files. | |
| `CB_PACKAGE_USER` | Username for accessing `CB_PACKAGE_URL`. | |
| `CB_PACKAGE_PASSWORD` | Password for `CB_PACKAGE_URL`. Set to `ask` for interactive prompt. | |


## Tool Version Defaults

The file `conf/tool-version-default.properties` defines the default version for every managed tool. When you run `cb --install <package>` without specifying a version, the version from this file is used. It is a simple `key = value` format:

```properties
java = 21
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


## Special Files

| File | Description |
|---|---|
| `.java-version` | Place in a project root to pin a specific Java version (e.g. `11`). |
| `conf/tool-version-default.properties` | Default versions for all tools. |
| `conf/tool-version-installed.properties` | Tracks currently installed tool versions. |
| `conf/project-types.properties` | Project type definitions for `cb --new`. |
| `conf/product-types.properties` | Product type definitions (optional). |


## Customization

### Custom Hook Script

Set `CB_CUSTOM_SETTING` to point to a shell script that will be called at various lifecycle hooks: `start`, `build-start`, `build-end`, `install-start`, `install-end`, `setenv-start`, `setenv-end`, `error-end`, and more. See `$CB_HOME/bin/sample/cb-custom-sample.sh` for a template.

### Custom Config Project

For organization-wide customization, create a Custom Config Home project (`cb --new`, select the organization-config template). Publish it as a git repository and set `CB_CUSTOM_CONFIG` to the git URL. Common-build checks for updates daily and applies the configuration automatically.

Alternatively, add the git URL to the file `$HOME/.common-build/conf/.cb-custom-config`.

For full details on setting up an organization config with custom tool versions, project types, product types, lifecycle hooks, and concrete examples, see the [Organization Config documentation](docs/organization-config.md).

