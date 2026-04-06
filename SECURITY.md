# Security

## Reporting a vulnerability

If you discover a security vulnerability in common-build, please report it privately by opening a [GitHub Security Advisory](https://github.com/toolarium/common-build/security/advisories/new) rather than a public issue.

Alternatively, contact the maintainers via the email address listed on the [toolarium GitHub organization profile](https://github.com/toolarium).

## Scope

common-build downloads and executes third-party binaries (Java, Gradle, Node, etc.), modifies the system PATH, writes to shell profiles (`.bashrc`, `.zshrc`), and on Windows modifies user environment variables via the registry. Vulnerabilities in any of these areas are in scope:

- Download URL manipulation or injection
- PATH or environment variable poisoning
- Unauthorized file modification during installation
- Shell profile injection
- Archive extraction path traversal

## Response

We will acknowledge reports within 7 days and aim to provide a fix or mitigation within 30 days, depending on severity.
