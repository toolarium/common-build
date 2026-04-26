# cb-container

A cross-platform container management tool for Docker and nerdctl (Rancher Desktop). Provides a unified CLI to list images, start/stop containers, connect interactively, view logs, scan for vulnerabilities, and more.

Available as `cb-container` (shell) and `cb-container.bat` (Windows batch). Both versions provide identical functionality.

## Runtime Detection

`cb-container` automatically detects the container runtime:
1. **nerdctl** is preferred if available (Rancher Desktop)
2. **docker** is used as fallback (Docker Desktop)

If neither is found, the script exits with an error.

## Quick Start

```bash
# List running containers
cb-container -l

# List all images
cb-container -l -a

# Filter images by name prefix
cb-container -l alpine

# Connect to a container (starts interactively if not running)
cb-container -i ubuntu

# Start a container (detached)
cb-container --start my-app

# Stop a container
cb-container --stop my-app

# View logs
cb-container --log my-app

# Scan for vulnerabilities
cb-container --scan my-app

# Scan all images
cb-container --scan -a
```

## Project-Aware Mode

When run from a directory containing `settings.gradle`, `cb-container` automatically detects the project name from the `rootProject.name` property.

```bash
# In a project directory with settings.gradle:
cb-container                     # lists only this project's images
cb-container --scan              # scans the project image
cb-container --start             # starts the project image
cb-container --stop              # stops the project container
cb-container --log               # shows logs of the project container
cb-container --delete            # deletes the project image
```

The `--list` / `-l` flag is **not** affected by project detection — it always shows all images (or filtered by an explicit prefix).

### Local Cache

When in a project directory, scan results are stored locally:
- **Default**: `build/container/`
- **Testing projects** (where `gradle.properties` has `projectType = testing`): `build/reports/testing/`

This keeps scan artifacts with the project instead of in the global temp directory.

## Commands

### Listing Images (`-l`, `--list`)

Show images with running container info. By default only images with running containers are shown.

```bash
cb-container -l                      # running containers only
cb-container -l -a                   # all images
cb-container -l alpine               # filter by name prefix (implies -a)
cb-container -l al                   # partial prefix match
cb-container -l --verbose            # includes summary: N image(s), M running.
```

Output columns: IMAGE ID, CONTAINER ID, CREATED, STARTED, SIZE, TAG. Sorted alphabetically by tag name. The header shows a right-aligned timestamp and image count.

When a filter prefix is provided, only images whose repository name or image ID starts with the prefix are shown, and `-a` (show all) is implied automatically.

### Connecting to Containers (`-i`, `--it`)

Connect to a running container interactively. If no container is running for the given image, starts one interactively with `-it --rm` (auto-removed on exit).

```bash
cb-container -i my-app               # by image name
cb-container -i my-app:1.0.0         # by specific tag
cb-container -i abc123               # by container ID
cb-container -i b2b5369197a8         # by image ID
cb-container -i ubuntu               # pulls + runs if not local
cb-container -i kali                 # alias for kalilinux/kali-rolling
cb-container -i ubuntu -s /bin/bash  # use bash as shell
```

When combined with `--start`, `-i` attaches after the detached start:
```bash
cb-container --start my-app -i       # start detached + connect
```

#### Distro Aliases

Short aliases are supported for common distributions:

| Alias | Maps to |
|-------|---------|
| `arch` | `archlinux` |
| `debian` | `library/debian` |
| `kali` | `kalilinux/kali-rolling` |

### Starting Containers (`--start`)

Start a container in detached mode (background). The container keeps running after the command returns.

```bash
cb-container --start my-app                  # resolves :latest or newest tag
cb-container --start my-app:1.0.0            # specific tag
cb-container --start 34b83c5c873f            # by image ID
```

If the image is not found locally, it tries to pull it (appending `:latest` if no tag specified).

If a container from the same image is already running, reports the existing container ID.

#### Combined with other options

```bash
cb-container --start my-app -i               # start + attach interactive shell
cb-container --start my-app -t               # start + tail logs
cb-container --start my-app --log 10         # start + show first 10 log lines
cb-container --start my-app --log 5- -t      # start + tail from line 5
```

### Stopping Containers (`--stop`)

Stop a running container by name, image name, or container/image ID.

```bash
cb-container --stop my-app                   # by image name
cb-container --stop my-app:1.0.0             # by specific tag
cb-container --stop abc123def456             # by container ID
cb-container --stop 34b83c5c873f             # by image ID
```

If the image doesn't exist, reports "Image not found" instead of "No running container found".

### Viewing Logs (`--log`)

Show logs of a running container.

```bash
cb-container --log my-app                    # full logs
cb-container --log my-app 10                 # first 10 lines
cb-container --log my-app 5-10               # lines 5 to 10
cb-container --log my-app 5-                 # from line 5 to end
cb-container --log my-app -7                 # lines 1 to 7
cb-container --log my-app 0                  # show nothing
```

#### Tailing Logs (`-t`, `--tail`)

Follow logs in real-time (like `tail -f`). Use with `--log`.

```bash
cb-container --log my-app -t                 # tail all logs
cb-container --log my-app 10- -t             # tail from line 10 onwards
```

Can be combined with `--start`:
```bash
cb-container --start my-app -t               # start + tail
cb-container --start my-app --log 5- -t      # start + tail from line 5
```

Log header is only shown with `--verbose`.

### Scanning for Vulnerabilities (`--scan`)

Scan images for security vulnerabilities using [trivy](https://trivy.dev). Results are cached with automatic invalidation.

```bash
cb-container --scan my-app                   # scan single image
cb-container --scan my-app,nginx:alpine      # scan multiple (comma-separated)
cb-container --scan alpine:3.16              # pulls if not local
cb-container --scan 34b83c5c873f             # by image ID
cb-container --scan -a                       # scan ALL images (list view with VULN column)
cb-container --scan -a -l my                 # scan all images filtered by prefix
cb-container --scan my-app -w               # wide output (full column widths)
cb-container --scan my-app -f               # force rescan (ignore cache)
```

#### Scan All Images (`--scan -a`)

When combined with `-a` / `--all`, scans every image and displays a list-style table with per-severity columns (**CRIT**, **HIGH**, **MED**, **LOW**) replacing SIZE and STARTED:

```
------------------------------------------------------------------------------------------------------------------------
IMAGE ID      CONTAINER ID  CREATED           CRIT HIGH MED  LOW  TAG
------------------------------------------------------------------------------------------------------------------------
25109184c71b  -             2026-01-28 02:18  2    11   5    2    alpine:latest
1487d0af5f52  -             2024-09-26 23:31  0    0    0    0    busybox:latest
------------------------------------------------------------------------------------------------------------------------
.: Scan completed [4s]
```

Scanning multiple comma-separated images uses the same list-style format:

```bash
cb-container --scan alpine,archlinux         # list-style with severity columns
cb-container --scan 25109184,237637c5        # by image ID prefixes
```

Can be combined with `-l <prefix>` to filter by image name or image ID prefix.

#### Wide Output (`-w`, `--wide`)

Shows full (untruncated) PACKAGE, INSTALLED, and FIXED columns with a wider separator line:

```bash
cb-container --scan my-app -w
```

#### Force Rescan (`-f`, `--force`)

Ignores cached results and forces a fresh trivy scan:

```bash
cb-container --scan my-app -f
```

#### CSV Output (`--csv`)

Output as semicolon-separated CSV. Suppresses separator lines and footers. Works with `--list -a`, `--scan -a`, and `--scan img1,img2`:

```bash
cb-container --list -a --csv                 # list all images as CSV
cb-container --scan -a --csv                 # scan all images as CSV
cb-container --scan -a -l my --csv           # scan filtered images as CSV
cb-container --scan img1,img2 --csv          # scan specific images as CSV
```

List CSV header: `IMAGE ID;CONTAINER ID;CREATED;STARTED;SIZE;TAG`
Scan CSV header: `IMAGE ID;CONTAINER ID;CREATED;CRIT;HIGH;MED;LOW;TAG`

#### Trivy Detection

If `trivy` is not in PATH, the script tries `source cb --setenv` (shell) or `call cb --setenv` (batch) to load the environment including `TRIVY_HOME`.

If trivy is still not found: `.: Trivy is not installed. Install with: cb --install trivy`

#### Output Format

Results are sorted by severity (CRITICAL, HIGH, MEDIUM, LOW) and displayed in a table:

```
------------------------------------------------------------------------------------------------------------------------
CVE ID                 SEV  PACKAGE                        INSTALLED      FIXED          TARGET      2026-04-23 16:30:21
------------------------------------------------------------------------------------------------------------------------
CVE-2026-28390         H    libcrypto3                     3.5.5-r0       3.5.6-r0       alpine:latest (alpine 3.23.3)
CVE-2026-28388         M    libcrypto3                     3.5.5-r0       3.5.6-r0       alpine:latest (alpine 3.23.3)
CVE-2026-2673          L    libcrypto3                     3.5.5-r0       3.5.6-r0       alpine:latest (alpine 3.23.3)
------------------------------------------------------------------------------------------------------------------------
Summary: 20 vulnerabilities (CRITICAL: 0, HIGH: 5, MEDIUM: 11, LOW: 4) [12s]
------------------------------------------------------------------------------------------------------------------------
```

- **SEV**: C = CRITICAL, H = HIGH, M = MEDIUM, L = LOW
- **PACKAGE**: truncated from left with `..` if too long (full width with `-w`)
- **INSTALLED / FIXED**: truncated from left with `..` if too long (full width with `-w`)
- **FIXED**: shows `-` when no fix is available; multiple fix versions shown on continuation lines
- **Duration**: shown in brackets at the end of the summary line
- **Multiple images**: when scanning comma-separated images, all results are combined with a single summary

#### Caching

Scan results are cached with filenames like `<imageId>-<YYYYMMDD-HHmmss>-trivy.json`, `.rows`, and `.counts`.

Cache is stored in:
- **Project directory**: `build/container/` (or `build/reports/testing/` for testing projects) when `settings.gradle` is present
- **Global temp**: `$CB_TEMP/cb-container/` otherwise

Cache is automatically invalidated when:
- A new day starts (day boundary)
- The image has been rebuilt (creation timestamp newer than cache)
- `--force` / `-f` is used

The `--verbose` flag shows cache status:
```
.: Using cached scan for 'my-app:latest'.
.: Image is newer than cache (20260423-120830 > 20260423-100000), rescanning.
.: Cache expired (from 20260422, today 20260423), rescanning.
.: Force scan, cache cleared for 'my-app:latest'.
```

### Deleting Images (`--delete`)

Delete an image by name or ID. Refuses if a container is currently running from the image.

```bash
cb-container --delete my-app                 # deletes :latest or newest tag
cb-container --delete my-app:0.0.1-SNAPSHOT  # specific tag
cb-container --delete 34b83c5c873f           # by image ID
```

### Cleaning Cache (`--clean`)

Remove cached scan results and prune dangling images.

```bash
cb-container --clean                         # clean (verbose when standalone)
cb-container --clean --scan my-app           # clean first, then scan
```

When `--clean` is the only action, verbose is forced automatically.

## Additional Options

### Shell Override (`-s`, `--shell`)

Set the shell for `-i`/`--it` (default: `/bin/sh`).

```bash
cb-container -i ubuntu -s /bin/bash
```

### Entrypoint Override (`-e`, `--entrypoint`)

Override the container's entrypoint.

```bash
cb-container --start my-app -e /bin/bash
cb-container -i my-app -e /custom/entrypoint
```

### Port Publishing (`-p`, `--port`)

Publish container ports. Single port maps to the same host port; with colon, taken as-is.

```bash
cb-container --start my-app -p 8080          # maps to -p 8080:8080
cb-container --start my-app -p 8081:8082     # maps to -p 8081:8082
cb-container --start my-app -p 8080 -p 9090  # multiple ports
```

### Environment Variables (`--env`)

Set environment variables (comma-separated key=value pairs).

```bash
cb-container --start my-app --env DB_HOST="localhost",DB_PORT="5432"
```

### Verbose Output (`--verbose`)

Show additional information like resolved image names, cache status, scan file paths, and list summaries.

```bash
cb-container -l --verbose
cb-container --scan my-app --verbose
```

## Configuration File (`.cb-container`)

If a `.cb-container` file exists in the current directory, its first line is read and prepended to the CLI arguments as default parameters.

Example `.cb-container`:
```
--env DB_HOST="localhost",DB_PORT="5432" -p 8080
```

Then running `cb-container --start my-app` is equivalent to:
```bash
cb-container --env DB_HOST="localhost",DB_PORT="5432" -p 8080 --start my-app
```

## Image Resolution

When an image name is provided without a tag, the script resolves the best match:

1. **`:latest`** tag is preferred
2. **Newest available tag** (first listed by the runtime) as fallback
3. **Image ID** -- full or short IDs are matched as prefixes
4. **Multi-tag matching** -- when an image ID has multiple tags, all are checked against running containers

When an image is not found locally (`--start`, `-i`, `--scan`):
- If the name contains `:` (explicit tag), tries to pull as-is
- If no `:`, appends `:latest` and tries to pull

## Positional Argument

An image name can be passed as a positional argument (without `--start`):

```bash
cb-container my-app                          # equivalent to --start my-app
```

## Auto-Build from Dockerfile

If no command is given and a `Dockerfile`, `dockerfile`, or `Containerfile` exists in the current directory, `cb-container` automatically builds and runs the image.

## Cross-Platform Compatibility

- **Windows**: `cb-container.bat` using `cmd.exe` with delayed expansion. Uses PowerShell for JSON parsing (trivy scan) and date formatting.
- **Linux / macOS**: `cb-container` shell script, compatible with bash 3.2+ (macOS default). Uses `awk` for JSON parsing.
- **MinGW / Git Bash**: Shell script works on Git Bash for Windows.

All container runtime commands are compatible with both Docker and nerdctl. Uses `|` as field separator in format strings for portability (nerdctl doesn't interpret `\t`).

## Temp Directory

Temporary and cache files are stored in:

- **In a project directory** (with `settings.gradle`): `build/container/` (or `build/reports/testing/` for testing projects)
- **Outside a project**: `$CB_TEMP/cb-container/` (shell) or `%CB_TEMP%\cb-container\` (batch)

If `CB_TEMP` is not set, defaults to `/tmp/cb-$USER` (shell) or `%TEMP%\cb` (batch).
