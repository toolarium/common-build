# Project Wizard (`cb --new`)

The project wizard creates new projects interactively. It guides you through product selection, project type selection, and project-specific configuration.

## Quick Start

```bash
cb --new
```

You can also prefill all wizard parameters from the command line:

```bash
cb --new [product-id] [project-type-id] [project-name] [package-name] [group-id] [component-id] [description...]
```

Example:

```bash
cb --new 1 1 my-service com.example.myservice example mycomp "A REST API service"
```


## Wizard Flow

### 1. Product Selection (optional)

If a `product-types.properties` file exists, the wizard displays a numbered list of products:

```
[1] My product
[2] Another product
```

Selecting a product pre-fills wizard defaults (group ID, component ID, root package name, etc.) so you don't have to enter them manually for every project.

If no `product-types.properties` exists, this step is skipped.

### 2. Project Type Selection

The wizard displays all available project types:

```
[1]  Simple java application
[2]  Simple java library
[3]  Configuration project
[4]  Script project
...
```

The selected project type determines which fields are prompted and what actions are executed.

### 3. Project Details

Depending on the selected project type, the wizard prompts for some or all of the following:

| Field | Description |
|---|---|
| **Project Name** | The project directory and artifact name. Some types append a suffix automatically (e.g. `-ui`, `-config`). |
| **Root Package Name** | Java package name (e.g. `com.example.myproject`). Only for Java-based types. |
| **Group ID** | Artifact group identifier, typically used for Maven/Gradle publishing. |
| **Component ID** | Optional component identifier that can be part of the project name. |
| **Description** | A short project description. Defaults to "The implementation of the {projectName}." |

### 4. Project Generation

After collecting input, the wizard:

1. **Installs dependencies** if the project type defines an `install` section (e.g. `node`).
2. **Runs the init action** if defined (e.g. `npx create-react-app`).
3. **Runs the main action** if defined. If no main action is set, the wizard creates a `build.gradle` using [common-gradle-build](https://github.com/toolarium/common-gradle-build) and runs Gradle.
4. **Runs the post action** if defined (e.g. cleanup tasks).


## Configuration

### `product-types.properties`

Defines organizational product groupings. Each product pre-fills wizard fields.

**Location:** `conf/product-types.properties` (see `conf/product-types-sample.properties` for a template)

**Syntax:**

```properties
<product-name> = <setting> [ | <setting> ]
```

Each setting is a `variableName:value` pair. Multiple settings are separated by `|`.

**Example:**

```properties
My product = projectComponentId:myc|projectGroupId:myg|projectRootPackageName:myc.rootpackage.name
```

When this product is selected, the wizard pre-fills:
- Component ID → `myc`
- Group ID → `myg`
- Root package name → `myc.rootpackage.name`

### `project-types.properties`

Defines available project types and their wizard configuration.

**Location:** `conf/project-types.properties`

**Syntax:**

```properties
<project-type-id> = <description> [ | <configuration-section> ]
```

**Configuration sections** control which fields are prompted and what actions are run:

| Section | Description |
|---|---|
| `projectName` | Prompt for project name. Append `=<suffix>` to auto-add a suffix (e.g. `projectName=-ui`). |
| `projectRootPackageName` | Prompt for Java root package name. |
| `projectGroupId` | Prompt for group ID. |
| `projectComponentId` | Prompt for component ID. |
| `projectDescription` | Prompt for project description. |
| `install=<pkg1>[,<pkg2>]` | Install dependencies before project creation (e.g. `install=node`). |
| `initAction=<command>` | Run a command before the main project generation. |
| `mainAction=<command>` | Run as the main generation step. If empty, common-gradle-build is used. |
| `postAction=<command>` | Run a command after project generation (e.g. cleanup). |

**Important:** The order of sections matters. `install`, `initAction`, `mainAction`, and `postAction` must appear after the field sections.

**Parameter substitution** in actions — the following tokens are replaced at runtime:

| Token | Replaced with |
|---|---|
| `@@projectName@@` | Entered project name |
| `@@projectType@@` | Selected project type |
| `@@projectRootPackageName@@` | Entered root package name |
| `@@projectGroupId@@` | Entered group ID |
| `@@projectComponentId@@` | Entered component ID |
| `@@projectDescription@@` | Entered description |
| `@@logFile@@` | `/dev/null` (Linux/Mac) or `nul` (Windows) |
| `@@delete@@` | `rm -rf` (Linux/Mac) or `cb-deltree` (Windows) |


## Available Project Types

| Type | Description | Suffix | Fields | Dependencies |
|---|---|---|---|---|
| `java-application` | Simple java application | — | name, package, group, component, description | — |
| `java-library` | Simple java library | — | name, package, group, component, description | — |
| `config` | Configuration project | `-config` | name, group, component, description | — |
| `script` | Script project | `-bin` | name, group, description | — |
| `openapi` | OpenAPI definition project | `-service-api-spec` | name, package, group, component, description | — |
| `quarkus` | REST-service with Quarkus | `-service` | name, package, group, component, description | — |
| `vuejs` | Vue | `-ui` | name, component, description | node |
| `nuxtjs` | Nuxt | `-ui` | name, component, description | node |
| `react` | React | `-ui` | name, component, description | node |
| `kubernetes-product` | Kubernetes product | `-app` | name, group, component, description | — |
| `documentation` | Documentation project | `-documentation` | name, group, description | — |
| `container` | Individual container (e.g. docker) | `-container` | name, component, description | — |
| `organization-config` | Common Organization Config | `-config` | name, group, description | — |


## Configuration File Resolution

The wizard searches for configuration files in this order (first found wins):

1. **Custom runtime config** — `$CB_CUSTOM_RUNTIME_CONFIG_PATH/conf/`
   - Also supports product-specific project types: `project-types-<productname>.properties`
2. **Local common-gradle-build** — `~/.gradle/common-gradle-build/<version>/gradle/conf/`
3. **Default** — `$CB_HOME/conf/`

This allows organizations to provide their own product and project types via a custom config project.


## Examples

Create a Java library interactively:

```bash
cb --new
# Select: java-library
# Enter: project name, package, group, component, description
```

Create a Vue.js project (installs Node automatically):

```bash
cb --new
# Select: vuejs
# Enter: project name, component, description
```

Fully scripted project creation:

```bash
cb --new 1 1 my-service com.example.myservice example mycomp "My new service"
```
