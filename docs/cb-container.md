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
```

## Commands

### Listing Images (`-l`, `--list`)

Show images with running container info. By default only images with running containers are shown.

```bash
cb-container -l                      # running containers only
cb-container -l -a                   # all images
cb-container -l --verbose            # includes summary: N image(s), M running.
```

Output columns: IMAGE ID, CONTAINER ID, CREATED, STARTED, SIZE, TAG. Sorted alphabetically by tag name. The header shows a right-aligned timestamp and image count.

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

Scan images for security vulnerabilities using [trivy](https://trivy.dev). Results are cached per day.

```bash
cb-container --scan my-app                   # scan single image
cb-container --scan my-app,nginx:alpine      # scan multiple (comma-separated)
cb-container --scan alpine:3.16              # pulls if not local
cb-container --scan 34b83c5c873f             # by image ID
```

#### Trivy Detection

If `trivy` is not in PATH, the script tries `source cb --setenv` (shell) or `call cb --setenv` (batch) to load the environment including `TRIVY_HOME`.

If trivy is still not found: `.: Trivy is not installed. Install with: cb --install trivy`

#### Output Format

Results are sorted by severity (CRITICAL, HIGH, MEDIUM, LOW) and displayed in a table:

```
------------------------------------------------------------------------------------------------------------------------
CVE ID                 SEV  PACKAGE                        INSTALLED      FIXED          TARGET      2026-04-19 16:30:21
------------------------------------------------------------------------------------------------------------------------
CVE-2026-28390         H    libcrypto3                     3.5.5-r0       3.5.6-r0       alpine:latest (alpine 3.23.3)
CVE-2026-28388         M    libcrypto3                     3.5.5-r0       3.5.6-r0       alpine:latest (alpine 3.23.3)
CVE-2026-2673          L    libcrypto3                     3.5.5-r0       3.5.6-r0       alpine:latest (alpine 3.23.3)
------------------------------------------------------------------------------------------------------------------------
Summary: 20 vulnerabilities (CRITICAL: 0, HIGH: 5, MEDIUM: 11, LOW: 4)
------------------------------------------------------------------------------------------------------------------------
```

- **SEV**: C = CRITICAL, H = HIGH, M = MEDIUM, L = LOW
- **PACKAGE**: truncated from left with `..` if too long
- **INSTALLED / FIXED**: truncated from left with `..` if too long
- **FIXED**: shows `-` when no fix is available; multiple fix versions shown on continuation lines
- **Multiple images**: when scanning comma-separated images, all results are combined with a single summary

#### Caching

Scan results are cached in `$CB_TEMP/cb-container/` with filenames like `<imageId>-<YYYYMMDD>-trivy.json` and `.rows`. On the same day, subsequent scans show the cached result instantly.

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

## Cross-Platform Compatibility

- **Windows**: `cb-container.bat` using `cmd.exe` with delayed expansion. Uses PowerShell for JSON parsing (trivy scan) and date formatting.
- **Linux / macOS**: `cb-container` shell script, compatible with bash 3.2+ (macOS default). Uses `awk` for JSON parsing.
- **MinGW / Git Bash**: Shell script works on Git Bash for Windows.

All container runtime commands are compatible with both Docker and nerdctl. Uses `|` as field separator in format strings for portability (nerdctl doesn't interpret `\t`).

## Temp Directory

All temporary files are stored in `$CB_TEMP/cb-container/` (shell) or `%CB_TEMP%\cb-container\` (batch). This includes scan caches, intermediate files, and error logs.

If `CB_TEMP` is not set, defaults to `/tmp/cb-$USER` (shell) or `%TEMP%\cb` (batch).
