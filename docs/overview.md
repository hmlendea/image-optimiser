# Image Optimiser - Documentation

## Repository Purpose

`image-optimiser` is a Linux shell utility that losslessly compresses image files (PNG, JPG, JPEG) in place. It recursively scans one or more paths, optimises supported files using external CLI tools, and reports per-file and total size reduction.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Input                                │
│                  (file/directory paths)                          │
└─────────────────────────┬───────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    src/optimise-image.sh                         │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────┐  │
│  │  find       │→ │  per-file    │→ │  format detection      │  │
│  │  (recursive)│  │  loop        │  │  (extension-based)     │  │
│  └─────────────┘  └──────────────┘  └───────────┬────────────┘  │
│                                                  ▼               │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────┐  │
│  │  size       │← │  optimiser   │← │  tool dispatch         │  │
│  │  reporting  │  │  invocation  │  │  (oxipng/jpegoptim/    │  │
│  └─────────────┘  └──────────────┘  │   zopflipng)           │  │
│                                     └────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Output                                      │
│  - Per-file: original size → optimised size                     │
│  - Summary: total images, total original → total final          │
└─────────────────────────────────────────────────────────────────┘
```

## Core Components

| Component | Path | Responsibility |
|-----------|------|----------------|
| Main script | `src/optimise-image.sh` | Recursive file discovery, format detection, tool dispatch, size reporting |
| Build script | `build-deb.sh` | Creates Debian package with AppStream metadata |
| CI workflow | `.github/workflows/bash.yml` | ShellCheck validation on push/PR |
| Release workflow | `.github/workflows/release-deb.yml` | Builds and uploads .deb on GitHub release |

## External Dependencies

| Tool | Format | Purpose | Required |
|------|--------|---------|----------|
| `oxipng` | PNG | Primary PNG optimiser (preferred) | Yes (or zopflipng) |
| `zopflipng` | PNG | Fallback PNG optimiser | Fallback only |
| `jpegoptim` | JPG/JPEG | JPEG optimiser | Yes |
| `find` | — | Recursive file discovery | Yes (GNU findutils) |
| `awk` | — | Size extraction from `du` | Yes (GNU gawk) |
| `du` | — | Byte-size measurement | Yes (GNU coreutils) |
| `numfmt` | — | Human-readable size formatting | Yes (GNU coreutils) |

## Design Decisions

- **In-place modification**: No output directory; original files are overwritten after optimisation
- **Lossless only**: All tools invoked with lossless flags (`--preserve`, `--strip-all`, etc.)
- **Recursive by default**: `find` with `-print0` handles spaces and special characters safely
- **Graceful degradation**: Falls back from `oxipng` to `zopflipng` if unavailable
- **No configuration file**: All behaviour controlled via CLI arguments (input paths)
- **Single-file script**: Entire logic in one Bash file for portability

## Distribution Channels

1. **GitHub Releases** - Source script and .deb package
2. **Debian package (.deb)** - Built via `build-deb.sh` or GitHub Actions, installs to `/usr/local/bin/image-optimiser`
3. **Direct script usage** - Download and run `src/optimise-image.sh` directly