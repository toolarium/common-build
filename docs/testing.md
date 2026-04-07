# Testing

This document describes how common-build is tested, the design decisions behind the test architecture, and how to run the tests locally or in CI.


## Design principles

### 1. Tool versions are controlled by common-build itself

All tools (Java, Gradle, Node, etc.) are installed via `cb --install <tool>` into the test sandbox. This guarantees that tests exercise the **exact versions** from `conf/tool-version-default.properties` — the same versions real users get. External GitHub Actions like `setup-java`, `setup-node`, or `setup-gradle` are intentionally **not** used, because version mismatches between an externally provided tool and the version cb expects can mask real incompatibilities. If a download URL breaks or a version is misconfigured, the CI test catches it.

### 2. The project working tree is never polluted

Every test creates a temporary `CB_HOME` sandbox under `$TMPDIR` / `%TEMP%`. Source files (`bin/`, `conf/`, `VERSION`) are symlinked or junction-linked into the sandbox. Downloaded tools and generated projects live exclusively in the temp directory and are cleaned up automatically when the test finishes. The repository's `current/`, `.repository/`, and working tree remain untouched.

### 3. Tests are gated for practical CI times

Scaffolding tests (fast, ~5 min) run on every push/PR on Linux, macOS, and Windows. Full build tests (slow, ~20–30 min) run only on a nightly schedule or via manual workflow dispatch. This keeps PR feedback fast while ensuring comprehensive coverage overnight.


## Test scripts

All test scripts live in `test/bin/` with cross-platform pairs (shell + `.bat`).

| Script | What it tests |
|---|---|
| `cb-test` | Core `cb` options: `--version`, `--help`, `--packages`, `--setenv`, `--setenv --silent` |
| `cb-project-test` | Project scaffolding (`cb --new`) for all 13 project types, plus optional build verification (`cb` in project dir) |
| `cb-clean-files-test` | `cb-clean-files` utility: help output, dangerous-path rejection, age-based deletion, dry-run, pattern filter |
| `cb-open-ports-test` | `cb-open-ports` utility: help output, invalid args, header display, quiet mode, file output |
| `cb-version-filter-test` | `cb-version-filter` utility: semver filtering logic |
| `cb-install-test` | `cb-install` bootstrap installer: `--help` and `--version` output validation |
| `cb-install-e2e-test` | End-to-end `cb-install`: downloads a real release from GitHub into a sandbox, verifies artifacts, shell-profile modification, cleanup rules (.git, test/ removed; docs/ kept) |
| `cb-filetail-test` | `cb-filetail` utility tests |


## How the sandbox works

```
$TMPDIR/cb-project-home-XXXX/        ← temp CB_HOME
├── bin/      → symlink to repo/bin/
├── conf/     → symlink to repo/conf/
├── VERSION   → symlink to repo/VERSION
└── current/
    ├── java/   → installed via cb --install java
    ├── gradle/ → installed via cb --install gradle
    └── node/   → installed via cb --install node (when NETWORK=1)
```

When `cb --new` or `cb` (build) runs inside this sandbox, all downloads and tool extractions land under the temp `current/` directory. The repository is never modified.


## cb-project-test in detail

### Project-type groups

| Group | Types | Tools needed | Default gate |
|---|---|---|---|
| **A — Gradle + Java** | java-application, java-library, openapi, quarkus | java, gradle | always (scaffold) |
| **B — Gradle-only** | config, script, kubernetes-product, documentation, container, organization-config | gradle (+ java for wizard) | always (scaffold) |
| **C — Node** | vuejs, nuxtjs, react | node + network (npx/npm) | `CB_PROJECT_TEST_NETWORK=1` |

### Two-phase testing

**Phase 1 — Scaffold** (always runs):
Invokes `cb --new <typeId> <name> <args>` for each project type and verifies:
- Project directory was created
- At least one scaffold file is present (`build.gradle`, `settings.gradle`, `README.md`, or `package.json`)

**Phase 2 — Build** (gated by `CB_PROJECT_TEST_BUILD=1`):
Invokes `cb` (no arguments) in the created project directory and verifies:
- Build exits with code 0
- On failure, the last 10 lines of the build log are printed for diagnosis

### Tool resolution order

For each tool (java, gradle, node):

1. **`CB_EXTERNAL_<TOOL>_HOME`** environment variable — link an existing install
2. **Auto-detect** from `c:\devtools\toolarium-common-build-*\current\<tool>` (Windows local convention)
3. **`cb --install <tool> --default`** into the sandbox — uses the version from `conf/tool-version-default.properties`

In CI, step 3 is what always runs (no external tools pre-installed). Locally, steps 1 or 2 save time by reusing an existing installation.


## Running tests locally

### Quick run (scaffold-only, no build)

```bash
# Linux / macOS / git-bash
bash test/bin/cb-project-test

# Windows
test\bin\cb-project-test.bat
```

If Java is not available locally and cannot be auto-detected, the test skips with a message.

### With build verification

```bash
CB_PROJECT_TEST_BUILD=1 bash test/bin/cb-project-test
```

This installs Java and Gradle into the sandbox (if not already linked) and runs `cb` in each scaffolded project.

### Including Node-based project types

```bash
CB_PROJECT_TEST_BUILD=1 CB_PROJECT_TEST_NETWORK=1 bash test/bin/cb-project-test
```

Adds Group C (vuejs, nuxtjs, react). Node is installed via `cb --install node --default` into the sandbox.

### Pointing at existing tool installations (skip download)

```bash
CB_EXTERNAL_JAVA_HOME=/path/to/java \
CB_EXTERNAL_GRADLE_HOME=/path/to/gradle \
CB_PROJECT_TEST_BUILD=1 \
bash test/bin/cb-project-test
```
As example:

```bash
CB_EXTERNAL_JAVA_HOME=/c/devtools/jdk-21.0.2+13 \
CB_EXTERNAL_GRADLE_HOME=/c/devtools/gradle-8.13 \
CB_PROJECT_TEST_BUILD=1 \
bash test/bin/cb-project-test
```

### Running all tests

```bash
# Shell
bash test/bin/cb-test
bash test/bin/cb-project-test
bash test/bin/cb-clean-files-test
bash test/bin/cb-open-ports-test
bash test/bin/cb-version-filter-test
bash test/bin/cb-install-test
CB_INSTALL_TEST_E2E=1 bash test/bin/cb-install-e2e-test

# Windows (cmd)
test\bin\cb-test.bat
test\bin\cb-project-test.bat
test\bin\cb-clean-files-test.bat
test\bin\cb-open-ports-test.bat
test\bin\cb-version-filter-test.bat
test\bin\cb-install-test.bat
set CB_INSTALL_TEST_E2E=1 && test\bin\cb-install-e2e-test.bat
```


## CI (GitHub Actions)

The workflow `.github/workflows/cb-test.yml` runs on every push/PR to `master` and on a nightly schedule. Shell tests run on both Linux and macOS (via matrix), batch tests run on Windows.

### Push / PR triggers

Fast tests only:
- `cb-test` — core command options
- `cb-project-test` — scaffold-only (no build phase)
- `cb-clean-files-test`, `cb-open-ports-test`, `cb-version-filter-test` — utility tests
- `cb-install-test` — installer help/version
- `cb-install-e2e-test` — full installer download into sandbox

### Nightly / manual dispatch

In addition to the above:
- `cb-project-test` with `CB_PROJECT_TEST_BUILD=1` and `CB_PROJECT_TEST_NETWORK=1` — full build verification for all 13 project types including Node-based ones

To trigger manually, go to **Actions → CB Test → Run workflow** and check **"Run full project build tests"**.


## Release workflow

The workflow `.github/workflows/cb-release.yml` automates version releases. It is triggered **manually only** via `workflow_dispatch`.

### Steps

1. **Validate** — checks that the version string is valid semver and the tag `v<version>` does not already exist. A tag that has been used cannot be reused.
2. **Test (Linux + Windows)** — runs the full test suite on both platforms. If any test fails, the release is aborted.
3. **Release** — on success:
   - Updates the `VERSION` file with the new version numbers
   - Commits the version bump
   - Creates an annotated git tag `v<version>`
   - Builds `.tgz` and `.zip` archives **excluding**: `.github/`, `test/`, `.gitattributes`, `.gitignore` (but **including** `docs/`)
   - Verifies the archive contents (excluded files absent, `docs/` present)
   - Pushes the tag and creates a GitHub release with the archives and changelog notes

### Usage

Go to **Actions → CB Release → Run workflow**:
- **version**: the release version, e.g. `1.1.0`
- **dry_run**: check this to validate + build archives without tagging or publishing

### Dry run

Always do a dry run first. It runs all tests, builds the archives, and shows their contents — but creates no tag and publishes no release. This lets you verify everything before committing.


## Environment variable reference

| Variable | Default | Description |
|---|---|---|
| `CB_PROJECT_TEST_BUILD` | (unset) | Set to `1` to enable build phase (run `cb` in each project) |
| `CB_PROJECT_TEST_NETWORK` | (unset) | Set to `1` to include Group C (vuejs, nuxtjs, react) |
| `CB_INSTALL_TEST_E2E` | (unset) | Set to `1` to run the end-to-end installer test |
| `CB_EXTERNAL_JAVA_HOME` | (auto-detect) | Path to an existing Java installation to link into sandbox |
| `CB_EXTERNAL_GRADLE_HOME` | (auto-detect) | Path to an existing Gradle installation to link into sandbox |
| `CB_EXTERNAL_NODE_HOME` | (auto-detect) | Path to an existing Node installation to link into sandbox |
| `CB_INSTALL_NO_PERSIST` | (unset) | Set to `true` to prevent `cb-install.bat` from writing to user registry (used by E2E test) |
