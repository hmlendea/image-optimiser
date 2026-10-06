# External Dependencies

## Overview

`image-optimiser` delegates all image compression to external CLI tools. This document details each dependency, its role, invocation patterns, and failure modes.

## Dependency Matrix

| Tool | Package (Debian/Ubuntu) | Package (Arch) | Package (Fedora) | Formats | Role |
|------|------------------------|----------------|------------------|---------|------|
| `oxipng` | `oxipng` | `oxipng` | `oxipng` | PNG | Primary PNG optimiser |
| `zopflipng` | `zopfli` | `zopfli` | `zopfli` | PNG | Fallback PNG optimiser |
| `jpegoptim` | `jpegoptim` | `jpegoptim` | `jpegoptim` | JPG/JPEG | JPEG optimiser |
| `find` | `findutils` | `findutils` | `findutils` | — | File discovery |
| `awk` | `gawk` | `gawk` | `gawk` | — | Text processing |
| `du` | `coreutils` | `coreutils` | `coreutils` | — | Size measurement |
| `numfmt` | `coreutils` | `coreutils` | `coreutils` | — | Size formatting |

## Tool Invocation Details

### oxipng (Primary PNG)

```bash
oxipng -o max --preserve --alpha "${IMAGE_PATH}"
```

| Flag | Purpose |
|------|---------|
| `-o max` | Maximum optimisation level (0-6, max=6) |
| `--preserve` | Preserve file timestamps and metadata |
| `--alpha` | Preserve alpha channel (don't strip transparency) |

**Behaviour:** Modifies file in-place. Exits 0 on success, non-zero on failure.

**Failure modes:**
- Not installed → script falls back to zopflipng
- Corrupt PNG → error output, non-zero exit, file may be unmodified
- Permission denied → error, file unmodified

### zopflipng (Fallback PNG)

```bash
zopflipng -y -m "${IMAGE_PATH}" "${IMAGE_PATH}"
```

| Flag | Purpose |
|------|---------|
| `-y` | Overwrite output file without prompting |
| `-m` | Maximum compression (iterations) |

**Behaviour:** Takes separate input and output paths. For in-place, both are same file.

**Failure modes:**
- Not installed → command not found, script fails (no further fallback)
- Corrupt PNG → error, non-zero exit
- Permission denied → error

### jpegoptim (JPEG)

```bash
jpegoptim --preserve --preserve-perms --all-progressive -o --strip-all "${IMAGE_PATH}"
```

| Flag | Purpose |
|------|---------|
| `--preserve` | Preserve file timestamps |
| `--preserve-perms` | Preserve file permissions |
| `--all-progressive` | Convert baseline JPEG to progressive |
| `-o` | Overwrite original file (in-place) |
| `--strip-all` | Strip all markers (EXIF, ICC profiles, comments, etc.) |

**Behaviour:** Modifies file in-place. Exits 0 on success.

**Failure modes:**
- Not installed → command not found, script fails
- Corrupt JPEG → error, non-zero exit
- Permission denied → error
- Already optimal → exits 0, file unchanged

## Core Utilities

### find

```bash
find "${INPUT_PATH}" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0
```

- `-type f` - Regular files only
- `-iname` - Case-insensitive name matching
- `-print0` - Null-delimited output (critical for filename safety)
- Parentheses group the extension alternatives

### du (Size Measurement)

```bash
du -b "${IMAGE_PATH}" | awk '{print $1}'
```

- `-b` - Apparent size in bytes (not disk usage blocks)
- Output format: `<size>\t<path>`
- `awk '{print $1}'` extracts size field

### numfmt (Human-Readable Formatting)

```bash
numfmt --to=iec <<< ${BYTES}
```

- `--to=iec` - IEC binary prefixes (KiB, MiB, GiB, etc.)
- Input via here-string
- Output: `1.5M`, `234K`, etc.

## Dependency Resolution Strategy

### PNG Optimisation Priority

```
1. oxipng (preferred)
   └─ if not found → 2. zopflipng
       └─ if not found → ERROR
```

**Rationale:** `oxipng` is faster and generally produces better compression. `zopflipng` is older but widely available.

### JPEG Optimisation

```
jpegoptim (required, no fallback)
```

**Rationale:** `jpegoptim` is the standard lossless JPEG optimiser. No common alternative with equivalent features.

## Installation Commands by Distribution

### Debian/Ubuntu

```bash
sudo apt update
sudo apt install -y oxipng jpegoptim coreutils findutils gawk
# zopfli provides zopflipng (optional fallback)
sudo apt install -y zopfli
```

### Arch Linux

```bash
sudo pacman -S --needed oxipng jpegoptim coreutils findutils gawk
# zopfli provides zopflipng
sudo pacman -S --needed zopfli
```

### Fedora

```bash
sudo dnf install -y oxipng jpegoptim coreutils findutils gawk
# zopfli provides zopflipng
sudo dnf install -y zopfli
```

## Version Compatibility

| Tool | Minimum Version | Notes |
|------|----------------|-------|
| `oxipng` | Any | `-o max` flag stable |
| `zopflipng` | Any | `-y -m` flags stable |
| `jpegoptim` | Any | All flags stable |
| `find` | GNU findutils 4.4+ | `-print0` required |
| `awk` | GNU awk 4.0+ | Standard features used |
| `du` | GNU coreutils 8.0+ | `-b` flag required |
| `numfmt` | GNU coreutils 8.22+ | `--to=iec` required |

## Runtime Detection

The script uses `command -v` for tool detection:

```bash
if command -v oxipng &>/dev/null; then
    # use oxipng
else
    # use zopflipng
fi
```

- `command -v` is POSIX-standard (preferred over `which`)
- `&>/dev/null` suppresses stdout/stderr
- Only checks PATH, not absolute paths

## Package Dependency Declarations

### build-deb.sh (Local Build)

```text
Depends: zopfli, jpegoptim
```

- Declares `zopfli` (provides `zopflipng`) as PNG dependency
- Does not declare `oxipng` (preferred but optional)
- Does not declare core utilities (assumed present)

### GitHub Actions Workflow

```text
Depends: bash, coreutils, findutils, gawk, oxipng, jpegoptim
```

- More complete: declares all runtime requirements
- Includes `oxipng` as primary PNG tool
- Includes core utilities explicitly

## Recommendations

1. **Align dependency declarations** between build-deb.sh and workflow
2. **Consider declaring oxipng** in build-deb.sh as Recommends or alternative
3. **Add version constraints** if specific features are needed
4. **Document fallback behaviour** in package description