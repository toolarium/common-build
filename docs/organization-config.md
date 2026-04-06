# Common Organization Config

In a corporate environment, organizations often need to enforce consistent tool versions, project structures, naming conventions, and custom validation rules across all development teams. The **Common Organization Config** feature allows you to centralize these settings in a Git repository that common-build automatically clones and applies.

## Overview

A custom config project is a Git repository containing organization-specific configuration files and lifecycle hook scripts. Once configured, common-build:

1. Clones the repository automatically on first use
2. Checks for updates daily
3. Applies the configuration (tool versions, project types, product types, hooks) to all `cb` operations

## Setting Up

### Step 1: Create the Config Project

Use the built-in wizard to scaffold the project:

```bash
cb --new
# Select: organization-config
# Enter: project name (e.g. "myorg"), group ID, description
# Result: myorg-config/ directory created
```

### Step 2: Add Your Configuration

Populate the project with your organization's settings (see [Project Structure](#project-structure) below).

### Step 3: Publish to Git

```bash
cd myorg-config
git init
git add .
git commit -m "Initial organization config"
git remote add origin https://github.com/myorg/myorg-config.git
git push -u origin master
```

### Step 4: Configure Developers

Each developer points common-build to the config repository using one of two methods.

**Option A: Environment Variable**

```bash
# Linux/Mac — add to .bashrc or .zshrc:
export CB_CUSTOM_CONFIG="https://github.com/myorg/myorg-config.git"

# Windows — set as User environment variable:
set CB_CUSTOM_CONFIG=https://github.com/myorg/myorg-config.git
```

**Option B: Configuration File**

Create `$HOME/.common-build/conf/.cb-custom-config` (Linux/Mac) or `%USERPROFILE%\.common-build\conf\.cb-custom-config` (Windows):

```properties
myorg-config=github.com/myorg
```

The file supports multiple entries for different organizations:

```properties
# Default config (used when no pattern matches)
default-config

# Pattern-based selection (matched against Git remote URL)
myorg-config=github.com/myorg
partner-config=gitlab.com/partner-org
internal-config=gitlab.internal.mycompany.com
```

When a developer runs `cb` inside a project, common-build reads the Git remote URL of the current repository and selects the config entry with the longest matching pattern. If no pattern matches (or the project has no remote), the entry without a pattern is used as the default.


## Project Structure

```
myorg-config/
├── VERSION
├── bin/
│   ├── cb-custom.bat
│   └── cb-custom.sh
└── conf/
    ├── tool-version-default.properties
    ├── project-types.properties
    ├── product-types.properties
    └── project-types-<productname>.properties
```

All files are optional. Only include what you need to customize.

### `VERSION`

A plain text file containing the version number (e.g. `1.0.0`). Common-build uses this to detect updates — when the remote VERSION changes, the config is re-cloned.

```
1.0.0
```

### `conf/tool-version-default.properties`

Overrides the default tool versions for your organization. Only list tools you want to override:

```properties
java = 17
gradle = 8.13
node = 22.0.0
```

### `conf/project-types.properties`

Replaces the default project types shown in `cb --new`. Define only the types relevant to your organization:

```properties
backend-service = Backend REST Service|projectName=-service|projectRootPackageName|projectGroupId|projectComponentId|projectDescription
frontend-app = Frontend Application|projectName=-ui|projectComponentId|projectDescription|install=node|initAction=npx --yes create-react-app @@projectName@@
shared-library = Shared Java Library|projectName=-lib|projectRootPackageName|projectGroupId|projectComponentId|projectDescription
config = Organization Config|projectName=-config|projectGroupId|projectDescription
```

See the [Project Wizard documentation](project-wizard.md) for the full syntax reference.

### `conf/product-types.properties`

Defines product groupings that pre-fill wizard fields:

```properties
Platform = projectComponentId:platform|projectGroupId:com.myorg.platform|projectRootPackageName:com.myorg.platform
Mobile App = projectComponentId:mobile|projectGroupId:com.myorg.mobile|projectRootPackageName:com.myorg.mobile
```

### `conf/project-types-<productname>.properties`

Product-specific project types. When a developer selects "Platform" as the product, common-build looks for `project-types-Platform.properties` and uses those types instead of the default `project-types.properties`:

```properties
# project-types-Platform.properties
platform-service = Platform Microservice|projectName=-service|projectRootPackageName|projectGroupId|projectComponentId|projectDescription
platform-library = Platform Shared Library|projectName=-lib|projectRootPackageName|projectGroupId|projectComponentId|projectDescription
```


## Configuration Resolution Priority

When common-build looks for configuration files, it checks these locations in order (first found wins):

| Priority | Location | Description |
|---|---|---|
| 1 | `$CB_CUSTOM_RUNTIME_CONFIG_PATH/conf/` | Organization custom config |
| 2 | `~/.gradle/common-gradle-build/<version>/gradle/conf/` | Local common-gradle-build |
| 3 | `$CB_HOME/conf/` | Built-in defaults |

This means your organization config always takes precedence over the built-in defaults.


## Lifecycle Hooks

Hook scripts allow your organization to run custom logic at every stage of the common-build lifecycle. Place your hooks in:

- `bin/cb-custom.sh` — Linux/Mac
- `bin/cb-custom.bat` — Windows

### Available Hooks

| Hook | When Called | Use Case |
|---|---|---|
| `start` | Early initialization | Set global variables, display banners |
| `verify-configuration` | Before build, after Java setup | Validate project configuration |
| `build-start` | Before build execution | Pre-build checks, notifications |
| `build-end` | After successful build | Post-build actions, metrics |
| `new-project-start` | Before project wizard | Set custom project types dynamically |
| `new-project-validate-name` | User enters project name | Enforce naming conventions |
| `new-project-validate-rootpackagename` | User enters package name | Enforce package naming rules |
| `new-project-validate-groupid` | User enters group ID | Enforce group ID standards |
| `new-project-validate-componentid` | User enters component ID | Enforce component ID rules |
| `new-project-validate-description` | User enters description | Validate description format |
| `new-project-end` | After wizard completes | Post-creation setup, Git init |
| `install-start` | Before package installation | Pre-install checks |
| `install-end` | After package installation | Post-install configuration |
| `download-package-start` | Before downloading a package | URL rewriting, proxy setup |
| `download-package-end` | After downloading a package | Checksum verification |
| `extract-package-start` | Before extracting a package | Pre-extract checks |
| `extract-package-end` | After extracting a package | Post-extract configuration |
| `setenv-start` | Before setting environment | Pre-environment setup |
| `setenv-end` | After setting environment | Additional PATH entries |
| `cleanup-start` | Before cleanup runs (`cb-cleanup`) | Pre-cleanup hooks, notifications |
| `cleanup-end` | After cleanup completes (`cb-cleanup`) | Post-cleanup reporting |
| `custom-config-update-end` | After config repository is updated | Notify about config changes |
| `error-end` | When a critical error occurs | Error reporting, alerting |

### Validation Hooks

The `new-project-validate-*` hooks must return a code:
- **0** — validation passed
- **1** — validation failed (wizard re-prompts the user)

Since hook scripts are **sourced** (not executed as a subprocess), use `return 0` / `return 1` in shell scripts — not `exit`, which would terminate the calling shell.

### Hook Script Examples

#### Linux/Mac (`bin/cb-custom.sh`)

```bash
#!/bin/bash

# Enforce that all project names start with the organization prefix
customNewProjectValidateName() {
    local projectName="$1"
    if [[ ! "$projectName" =~ ^myorg- ]]; then
        echo "ERROR: Project name must start with 'myorg-' (got: $projectName)"
        return 1
    fi
    return 0
}

# Enforce Java package naming convention
customNewProjectValidateRootPackageName() {
    local packageName="$1"
    if [[ ! "$packageName" =~ ^com\.myorg\. ]]; then
        echo "ERROR: Package name must start with 'com.myorg.' (got: $packageName)"
        return 1
    fi
    return 0
}

# Pin corporate Java version on build start
customBuildStart() {
    echo "Using corporate Java version: $CB_JAVA_VERSION"
}

# Initialize Git repository after project creation
customNewProjectEnd() {
    echo "Initializing Git repository..."
    cd "$1" 2>/dev/null
    git init -q
    git add .
    git commit -q -m "Initial project setup"
}

# Log errors to a central location
customErrorEnd() {
    echo "ERROR: $*" >> "$HOME/.common-build/error.log"
}

# Dynamically define project types at runtime
customNewProjectStart() {
    CB_CUSTOM_PROJECT_CONFIGFILE=$(mktemp /tmp/cb-project-types.XXXXXXXXX)
    echo "backend-service = Backend Service|projectName=-service|projectRootPackageName|projectGroupId|projectComponentId|projectDescription" >> "$CB_CUSTOM_PROJECT_CONFIGFILE"
    echo "frontend-app = Frontend App|projectName=-ui|projectComponentId|projectDescription|install=node" >> "$CB_CUSTOM_PROJECT_CONFIGFILE"
}

# Clean up temporary files
customNewProjectEnd() {
    rm -f "$CB_CUSTOM_PROJECT_CONFIGFILE" 2>/dev/null
}

# Hook dispatcher — routes lifecycle events to functions
while [ $# -gt 0 ]; do
    case "$1" in
        start)                                shift; return 0;;
        verify-configuration)                 shift; return 0;;
        build-start)                          shift; customBuildStart "$@"; return 0;;
        build-end)                            shift; return 0;;
        new-project-start)                    shift; customNewProjectStart "$@"; return 0;;
        new-project-validate-name)            shift; customNewProjectValidateName "$@"; return 0;;
        new-project-validate-rootpackagename) shift; customNewProjectValidateRootPackageName "$@"; return 0;;
        new-project-validate-groupid)         shift; return 0;;
        new-project-validate-componentid)     shift; return 0;;
        new-project-validate-description)     shift; return 0;;
        new-project-end)                      shift; customNewProjectEnd "$@"; return 0;;
        install-start)                        shift; return 0;;
        install-end)                          shift; return 0;;
        download-package-start)               shift; return 0;;
        download-package-end)                 shift; return 0;;
        extract-package-start)                shift; return 0;;
        extract-package-end)                  shift; return 0;;
        setenv-start)                         shift; return 0;;
        setenv-end)                           shift; return 0;;
        cleanup-start)                        shift; return 0;;
        cleanup-end)                          shift; return 0;;
        custom-config-update-end)             shift; return 0;;
        error-end)                            shift; customErrorEnd "$@"; return 0;;
        *)                                    return 0;;
    esac
    shift
done
```

#### Windows (`bin/cb-custom.bat`)

```batch
@ECHO OFF

:: Hook dispatcher
if .%1==. goto CUSTOM_END
if .%1==.start shift & goto CUSTOM_END
if .%1==.verify-configuration shift & goto CUSTOM_END
if .%1==.build-start shift & goto CUSTOM_BUILD_START
if .%1==.build-end shift & goto CUSTOM_END
if .%1==.new-project-start shift & goto CUSTOM_END
if .%1==.new-project-validate-name shift & goto CUSTOM_NEW_PROJECT_VALIDATE_NAME
if .%1==.new-project-validate-rootpackagename shift & goto CUSTOM_NEW_PROJECT_VALIDATE_ROOTPACKAGENAME
if .%1==.new-project-validate-groupid shift & goto CUSTOM_END
if .%1==.new-project-validate-componentid shift & goto CUSTOM_END
if .%1==.new-project-validate-description shift & goto CUSTOM_END
if .%1==.new-project-end shift & goto CUSTOM_END
if .%1==.install-start shift & goto CUSTOM_END
if .%1==.install-end shift & goto CUSTOM_END
if .%1==.download-package-start shift & goto CUSTOM_END
if .%1==.download-package-end shift & goto CUSTOM_END
if .%1==.extract-package-start shift & goto CUSTOM_END
if .%1==.extract-package-end shift & goto CUSTOM_END
if .%1==.setenv-start shift & goto CUSTOM_END
if .%1==.setenv-end shift & goto CUSTOM_END
if .%1==.cleanup-start shift & goto CUSTOM_END
if .%1==.cleanup-end shift & goto CUSTOM_END
if .%1==.custom-config-update-end shift & goto CUSTOM_END
if .%1==.error-end shift & goto CUSTOM_ERROR_END
goto CUSTOM_END

:CUSTOM_BUILD_START
echo %CB_LINEHEADER%Using corporate Java version: %CB_JAVA_VERSION%
goto CUSTOM_END

:CUSTOM_NEW_PROJECT_VALIDATE_NAME
:: Enforce project name starts with "myorg-"
echo %1 | findstr /B "myorg-" >nul
if errorlevel 1 (
    echo ERROR: Project name must start with "myorg-" ^(got: %1^)
    exit /b 1
)
exit /b 0

:CUSTOM_NEW_PROJECT_VALIDATE_ROOTPACKAGENAME
:: Enforce package name starts with "com.myorg."
echo %1 | findstr /B "com.myorg." >nul
if errorlevel 1 (
    echo ERROR: Package name must start with "com.myorg." ^(got: %1^)
    exit /b 1
)
exit /b 0

:CUSTOM_ERROR_END
echo ERROR: %1 %2 %3 %4 %5 %6 %7 %8 %9 >> "%USERPROFILE%\.common-build\error.log"
goto CUSTOM_END

:CUSTOM_END
```


## Using CB_CUSTOM_SETTING Standalone

If you don't need the full custom config project (Git repository, versioning, auto-updates) but still want lifecycle hooks, you can point `CB_CUSTOM_SETTING` directly to a hook script:

```bash
# Linux/Mac
export CB_CUSTOM_SETTING="$HOME/my-cb-hooks.sh"

# Windows
set CB_CUSTOM_SETTING=%USERPROFILE%\my-cb-hooks.bat
```

The script receives the same lifecycle events as `bin/cb-custom.sh` in a custom config project. See the [sample scripts](sample/) for complete templates:

- [`cb-custom-sample.sh`](sample/cb-custom-sample.sh) — Linux/Mac sample with all hooks active and echo output
- [`cb-custom-sample.bat`](sample/cb-custom-sample.bat) — Windows sample with all hooks active and echo output
- [`cb-custom.sh`](sample/cb-custom.sh) — Linux/Mac minimal template (all hooks are no-ops)
- [`cb-custom.bat`](sample/cb-custom.bat) — Windows minimal template (all hooks are no-ops)


## Environment Variables

The following variables are available inside hook scripts:

| Variable | Description |
|---|---|
| `CB_HOME` | Common-build installation directory |
| `CB_DEVTOOLS` | Root directory for all dev tools |
| `CB_BIN` | Common-build bin directory |
| `CB_LINEHEADER` | Formatted line header for consistent output |
| `CB_LINE` | Separator line for formatted output |
| `CB_JAVA_VERSION` | Currently active Java version |
| `CB_CUSTOM_CONFIG` | Git URL of the custom config |
| `CB_CUSTOM_CONFIG_VERSION` | Current version of the custom config |
| `CB_CUSTOM_RUNTIME_CONFIG_PATH` | Full path to the active custom config version |
| `CB_CUSTOM_PROJECT_CONFIGFILE` | Path to dynamically generated project types (set in `new-project-start`) |


## Private Package Repository

Organizations can host additional software packages (as zip files) on an internal server. Common-build downloads and installs all packages from that URL when `cb --install` is called without a specific package name.

Set the following environment variables:

```bash
# Linux/Mac
export CB_PACKAGE_URL="https://packages.mycompany.com/devtools/"
export CB_PACKAGE_USER="myuser"
export CB_PACKAGE_PASSWORD="ask"

# Windows
set CB_PACKAGE_URL=https://packages.mycompany.com/devtools/
set CB_PACKAGE_USER=myuser
set CB_PACKAGE_PASSWORD=ask
```

| Variable | Description |
|---|---|
| `CB_PACKAGE_URL` | URL to a directory containing `.zip` package files. Common-build recursively downloads all zip files from this location. |
| `CB_PACKAGE_USER` | Username for authentication. If not set, the user is prompted interactively. |
| `CB_PACKAGE_PASSWORD` | Password for authentication. Set to `ask` to be prompted securely on the command line. |

The packages are downloaded via `wget` into the local dev repository, then extracted and linked just like built-in packages. This allows organizations to distribute proprietary or pre-configured tools that are not part of the public common-build package catalog.


## Update Mechanism

Common-build checks for config updates once per day:

1. On first `cb` run of the day, it fetches the remote `VERSION` file
2. If the version has changed, it clones the new version alongside the old one
3. The new version becomes active immediately
4. Old versions are preserved (allowing rollback by changing VERSION)

To force an immediate update:

```bash
cb --update
```

To force a re-download:

```bash
cb --update --force
```
