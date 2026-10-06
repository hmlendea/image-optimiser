# Privacy and Personal Data

This document describes how `image-optimiser` handles personal data. The application is a local command-line utility that runs entirely on the user's machine with no network connectivity, no data collection, and no external integrations.

**Information reviewed:** 2026-10-06

## 📑 Table of Contents

- What This Document Covers
- Self-Hosted Deployments
- Data We Handle
- Processing and Use
- Storage, Retention, and Deletion
- External Processing and Integrations
- Document Changes
- Contact

## 🔎 What This Document Covers

This document describes how `image-optimiser` at https://github.com/hmlendea/image-optimiser handles personal data. It covers the application behaviour and verified integrations described below. Where the software is self-hosted, the instance operator may have separate responsibilities described below.

## 🏠 Self-Hosted Deployments

`image-optimiser` is distributed as a standalone script and Debian package that users install and operate on their own machines. The project maintainers do not operate any hosted instance of this software.

Instance operators (users who install and run the tool) have full control over:
- Configuration (there is none; all behaviour is via CLI arguments)
- Local storage (the tool reads and writes only the image files explicitly provided as arguments)
- Logs (the tool produces no logs; output is printed to stdout/stderr only during execution)
- Backups (the tool modifies files in place; operators are responsible for their own backups)
- Access controls (the tool runs with the operator's user privileges)
- Retention (the tool does not retain any data after execution completes)
- Request handling (no personal data is processed, so no requests apply)

No data is sent from a self-hosted instance to project maintainers or any external service. The application makes no network connections, performs no update checks, sends no telemetry, and has no crash reporting.

## 📥 Data We Handle

### Data Provided to the Application

No personal data is requested or provided to the application. The tool accepts only file system paths to image files (PNG, JPG, JPEG) as command-line arguments.

### Data Generated or Collected by the Application

No personal data is generated or collected automatically. The tool outputs only:
- Per-file size reduction information (original size → optimised size)
- Summary totals (count of images processed, total original size → total final size)

This output contains no personal data; it describes only the image files explicitly provided by the user.

### Data Received from Integrations

No personal data is received from integrations or third parties. The application has no integrations.

## 🧭 Processing and Use

The application processes the data described above for these verified functions:
- Image file optimisation — Image file paths and contents provided by the user as CLI arguments
- Size measurement and reporting — File sizes before and after optimisation

No other processing occurs.

## 🗄️ Storage, Retention, and Deletion

The application does not store any data persistently. All processing occurs in memory during execution:

- Image files are read from and written to the exact paths provided by the user (in-place modification)
- No databases, caches, or temporary files are created by the application itself
- External tools (`oxipng`, `zopflipng`, `jpegoptim`) may create temporary files during optimisation; their behaviour is governed by their own implementations
- No data is retained after the process exits
- The instance operator controls all file system storage, backups, and deletion of their image files

## 🔗 External Processing and Integrations

The application has no built-in external data transfer. It invokes the following local CLI tools as subprocesses, which run entirely on the local machine:

| Service or integration | Purpose | Data involved | Configuration or documentation |
|-----------------------|---------|---------------|--------------------------------|
| `oxipng` | PNG optimisation | Image file contents (local file) | https://github.com/shssoichiro/oxipng |
| `zopflipng` | PNG optimisation (fallback) | Image file contents (local file) | https://github.com/google/zopfli |
| `jpegoptim` | JPEG optimisation | Image file contents (local file) | https://github.com/tjko/jpegoptim |

These tools process only the image files explicitly passed to them by the application. They make no network connections and transmit no data externally.

## 🛡️ Data Protection and Security

The application itself implements no data protection mechanisms because it handles no personal data. Security considerations for the instance operator:

- The tool runs with the operator's user privileges; it does not elevate privileges
- File permissions are preserved where supported by the backend tools (`--preserve-perms` for jpegoptim, `--preserve` for oxipng)
- The operator is responsible for securing their own file system, backups, and access controls
- No secrets, credentials, or authentication tokens are used or stored
- The operator should verify the integrity of installed dependencies (`oxipng`, `jpegoptim`, `zopfli`) through their distribution's package manager

## 🔄 Document Changes

Update this document when application data flows, storage, integrations, or deployment responsibilities change. The current version is published at https://github.com/hmlendea/image-optimiser/blob/master/PRIVACY.md.

## 📬 Contact

For questions about application data handling, contact the project maintainers via GitHub issues at https://github.com/hmlendea/image-optimiser/issues. For a self-hosted instance, the instance operator is the user running the tool; no separate contact applies. Do not send passwords, access tokens, or other secrets.