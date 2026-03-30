# common-build 
[![License](https://img.shields.io/github/license/toolarium/common-build)](https://opensource.org/licenses/GPL-3.0)

<img align="right" height="110" src="docs/logo/common-build-icon.png">

The common-build project has the goal to simplify the development environment setup. It works for the main environment such as Linux, Windows and Mac.
It can be used as a "transparent" wrapper of the most common build tools such as Gradle, Maven or Ant.

It simplifies additional the installation of tools e.g. java versions. All software will be installed in a so called "devtools" directory. All settings you can overwrite
by corresponding environment variables.



## Installing common-build

### Using script to install the latest release

**Windows**

Install the latest windows cli to `c:\devtools` and add this directory to User PATH environment variable.

```powershell
powershell -Command "iwr https://git.io/JJenc -OutFile ${env:TEMP}/cb-install.bat" & %TEMP%\cb-install.bat
```
or with full link
```powershell
powershell -Command "iwr https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install.bat -OutFile ${env:TEMP}/cb-install.bat" & %TEMP%\cb-install.bat
```
The common-build supports also cygwin. Please just use the Linux installation.
Currently only Windows 10 is properly tested.


**Linux**

Install the latest linux cli to `$HOME/devtools`

```bash
curl -fsSL https://git.io/JJezw | /bin/bash
```

or with full link
```bash
curl -fsSL https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install | /bin/bash
```
Currenlty it's tested on debian, ubuntu, centos and fedora.

**MacOS** (please support me for testing)

Install the latest mac cli to `$HOME/devtools`

```bash
curl -fsSL https://git.io/JJezw | /bin/bash
```

or with full link
```bash
curl -fsSL https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install | /bin/bash
```

Currently it's not final tested.


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
| `--setenv` | Set all internal environment variables (adds installed tools to `PATH`). |
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
| ant | 1.10.15 | Apache Ant build tool |
| btrace | 2.2.6 | BTrace dynamic tracing tool |
| eclipse | 2026-03 | Eclipse IDE (JEE package) |
| flutter | 3.41.5 | Flutter SDK |
| gaiden | 1.3 | Gaiden documentation tool |
| gradle | 8.13 | Gradle build tool |
| groovy | 4.0.31 | Apache Groovy |
| intellij | 2025.2.6.1 | IntelliJ IDEA |
| java | 21 | Java JDK |
| jmeter | 5.6.3 | Apache JMeter |
| maven | 3.9.14 | Apache Maven |
| micronaut | 4.10.18 | Micronaut framework CLI |
| node | 24.14.1 | Node.js |
| python | 3.13.12 | Python |
| rust | | Rust toolchain |
| sbt | 1.12.8 | Scala Build Tool |
| trivy | 0.69.3 | Trivy security scanner |
| visualvm | 2.2.1 | VisualVM profiler |
| vscode | 1.113.0 | Visual Studio Code |

Windows-only packages: `git`, `npp` (Notepad++), `multicommander`, `winmerge`, `wt` (Windows Terminal), `scoop`, `docker`, `postman`, `insomnia`, `squirrel`, `rangerdesktop`.


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

Set up environment (add tools to PATH):
```bash
# In .bashrc / .zshrc:
export PATH="${PATH}:$(cb --setenv | sed 's/^.*(//;s/).*//g' | xargs | sed 's/ /:/g')"
```

List available packages:
```bash
cb --packages
```

Create a new project:
```bash
cb --new
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


## Special Files

| File | Description |
|---|---|
| `.java-version` | Place in a project root to pin a specific Java version (e.g. `11`). |
| `conf/tool-version-default.properties` | Default versions for all tools. |
| `conf/tool-version-installed.properties` | Tracks currently installed tool versions. |


## Customization

### Custom Hook Script

Set `CB_CUSTOM_SETTING` to point to a shell script that will be called at various lifecycle hooks: `start`, `build-start`, `build-end`, `install-start`, `install-end`, `setenv-start`, `setenv-end`, `error-end`, and more. See `$CB_HOME/bin/sample/cb-custom-sample.sh` for a template.

### Custom Config Project

For organization-wide customization, create a Custom Config Home project (`cb --new`, select the config template). Publish it as a git repository and set `CB_CUSTOM_CONFIG` to the git URL. Common-build checks for updates daily and applies the configuration automatically.

Alternatively, add the git URL to the file `$HOME/.common-build/conf/custom-config.properties`.

