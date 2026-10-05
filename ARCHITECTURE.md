# Architecture

## Overview

`image-optimiser` is a single-file Bash utility that losslessly compresses PNG, JPG, and JPEG images in place. It delegates actual compression to external CLI tools and provides a unified interface with progress reporting.

## Components

| Component | Path | Responsibility |
|-----------|------|----------------|
| Main script | `src/optimise-image.sh` | Recursive file discovery, format detection, tool dispatch, size reporting |
| Build script | `build-deb.sh` | Creates Debian package with AppStream metadata |

## Data Flow

```
User paths → find (recursive) → per-file loop
    → detect extension (png/jpg/jpeg)
    → measure original size (du -b)
    → invoke optimiser (oxipng/zopflipng/jpegoptim)
    → measure final size
    → print per-file delta
    → accumulate totals
→ print summary
```

## External Dependencies

| Tool | Format | Purpose |
|------|--------|---------|
| `oxipng` | PNG | Primary PNG optimiser (preferred) |
| `zopflipng` | PNG | Fallback PNG optimiser |
| `jpegoptim` | JPG/JPEG | JPEG optimiser |
| `find`, `awk`, `du`, `numfmt` | — | Core utilities (GNU coreutils/findutils) |

## Build & Packaging

- `build-deb.sh <version>` produces `image-optimiser_<version>_all.deb`
- Installs script to `/usr/local/bin/image-optimiser`
- Includes AppStream metainfo for GNOME Software integration
- Declares runtime dependencies: `zopfli`, `jpegoptim`

## Design Decisions

- **In-place modification**: No output directory; original files are overwritten after optimisation
- **Lossless only**: All tools invoked with lossless flags (`--preserve`, `--strip-all`, etc.)
- **Recursive by default**: `find` with `-print0` handles spaces and special characters safely
- **Graceful degradation**: Falls back from `oxipng` to `zopflipng` if unavailable
- **No configuration file**: All behaviour controlled via CLI arguments (input paths)