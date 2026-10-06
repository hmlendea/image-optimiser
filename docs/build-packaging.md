# Build & Packaging - build-deb.sh

## Purpose

Creates a Debian package (.deb) from the project source, including the main script, AppStream metadata, and proper Debian control file.

## Entry Point

```bash
./build-deb.sh <version>
```

- Requires version argument (e.g., `1.0.0`)
- Outputs `image-optimiser_<version>_all.deb` in current directory

## Execution Flow

### 1. Argument Validation

```bash
VERSION="${1}"
if [[ -z "${VERSION}" ]]; then
    echo "Error: version parameter is required." >&2
    echo "Usage: $0 <version>" >&2
    exit 1
fi
```

- Exits with error if version not provided
- Uses `set -e` for fail-fast on any command failure

### 2. Temporary Build Directory

```bash
BUILD_DIR="$(mktemp -d)"
DEB_ROOT="${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}_${ARCH}"
```

- Creates isolated temporary directory
- Package root follows Debian naming convention: `name_version_arch`

### 3. Directory Structure Creation

```bash
mkdir -p "${DEB_ROOT}/usr/local/bin"
mkdir -p "${DEB_ROOT}/DEBIAN"
mkdir -p "${DEB_ROOT}/usr/share/metainfo"
```

| Directory | Purpose |
|-----------|---------|
| `usr/local/bin` | Installed executable location |
| `DEBIAN` | Debian control files |
| `usr/share/metainfo` | AppStream metadata for GNOME Software |

### 4. Script Installation

```bash
cp src/optimise-image.sh "${DEB_ROOT}/usr/local/bin/${PACKAGE_NAME}"
chmod 755 "${DEB_ROOT}/usr/local/bin/${PACKAGE_NAME}"
```

- Copies main script to `/usr/local/bin/image-optimiser`
- Sets executable permissions

### 5. AppStream Metainfo Generation

```xml
<?xml version="1.0" encoding="UTF-8"?>
<component type="console-application">
  <id>io.github.hmlendea.${PACKAGE_NAME}</id>
  <metadata_license>FSFAP</metadata_license>
  <project_license>GPL-3.0-only</project_license>
  <name>image-optimiser</name>
  <summary>Lossless image optimiser for PNG, JPG, and JPEG files</summary>
  <description>
    <p>
      A shell utility that losslessly compresses image files in place. It recursively scans one or more paths, optimises supported files using oxipng or zopflipng (PNG) and jpegoptim (JPG/JPEG), and reports per-file and total size reduction.
    </p>
  </description>
  <url type="homepage">https://github.com/hmlendea/image-optimiser</url>
</component>
```

- Written to `/usr/share/metainfo/io.github.hmlendea.image-optimiser.metainfo.xml`
- Enables integration with GNOME Software and other AppStream consumers
- Uses reverse-DNS ID format

### 6. Debian Control File Generation

```text
Package: image-optimiser
Version: <version>
Section: utils
Priority: optional
Architecture: all
Depends: zopfli, jpegoptim
Maintainer: hmlendea <https://github.com/hmlendea>
Homepage: https://github.com/hmlendea/image-optimiser
License: GPL-3.0
Description: Lossless image optimiser for PNG, JPG, and JPEG files.
 A shell utility that losslessly compresses image files in place...
```

**Key fields:**
- `Architecture: all` - Architecture-independent (Bash script)
- `Depends: zopfli, jpegoptim` - Runtime dependencies (note: `zopfli` provides `zopflipng`)
- `Section: utils` - Package category

### 7. Package Building

```bash
dpkg-deb --build --root-owner-group "${DEB_ROOT}" "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
```

- `--root-owner-group` - Sets ownership to root:root in package
- Outputs .deb in current working directory

### 8. Cleanup

```bash
rm -rf "${BUILD_DIR}"
echo "Built: ${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
```

- Removes temporary build directory
- Reports output filename

## Differences from GitHub Actions Workflow

| Aspect | build-deb.sh | .github/workflows/release-deb.yml |
|--------|--------------|-----------------------------------|
| Install path | `/usr/local/bin` | `/usr/bin` |
| Dependencies | `zopfli, jpegoptim` | `bash, coreutils, findutils, gawk, oxipng, jpegoptim` |
| Documentation | AppStream metainfo only | README.md + LICENSE in `/usr/share/doc` |
| Control file | Maintainer: GitHub URL | Maintainers: email placeholder |
| Build environment | Local machine | Ubuntu-latest runner |

## Dependency Notes

**build-deb.sh declares:**
- `zopfli` - Provides `zopflipng` binary (fallback PNG optimiser)
- `jpegoptim` - Primary JPEG optimiser

**GitHub Actions declares additionally:**
- `bash, coreutils, findutils, gawk` - Core utilities (usually pre-installed)
- `oxipng` - Primary PNG optimiser (preferred over zopflipng)

**Runtime reality:** The script works with either `oxipng` OR `zopflipng` for PNG, and requires `jpegoptim` for JPEG. The GitHub Actions dependency list is more complete for ensuring functionality.

## Output Package Structure

```
image-optimiser_<version>_all.deb
├── DEBIAN/
│   └── control
├── usr/
│   ├── local/
│   │   └── bin/
│   │       └── image-optimiser
│   └── share/
│       └── metainfo/
│           └── io.github.hmlendea.image-optimiser.metainfo.xml
```

## Installation & Usage

```bash
# Build
./build-deb.sh 1.0.0

# Install
sudo dpkg -i image-optimiser_1.0.0_all.deb

# Run
image-optimiser ./photos
```

## Verification

```bash
# Inspect package contents
dpkg -c image-optimiser_1.0.0_all.deb

# Inspect control file
dpkg -I image-optimiser_1.0.0_all.deb

# Verify installation
dpkg -L image-optimiser
```