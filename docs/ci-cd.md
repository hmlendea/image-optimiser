# CI/CD Pipelines

## Overview

Two GitHub Actions workflows provide continuous integration and release automation.

## Workflow 1: Bash Validation (.github/workflows/bash.yml)

### Trigger

```yaml
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
  workflow_dispatch:
```

- Runs on every push to master
- Runs on every PR targeting master
- Manually triggerable

### Job: check

```yaml
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run a one-line script
        run: shellcheck *.sh --severity error
```

**Purpose:** Static analysis of all shell scripts using ShellCheck

**Scope:** Checks all `*.sh` files in repository root (currently `build-deb.sh` only; `src/optimise-image.sh` not checked due to glob pattern)

**Configuration:**
- `--severity error` - Only report errors (not warnings/style)
- Fails build on any ShellCheck error

**Limitations:**
- Does not check `src/optimise-image.sh` (glob `*.sh` doesn't recurse)
- Uses older `actions/checkout@v2` (current is v4)
- No testing of actual script execution

## Workflow 2: Release Debian Package (.github/workflows/release-deb.yml)

### Trigger

```yaml
on:
  release:
    types: [published]
```

- Runs only when a GitHub Release is published (not draft, not pre-release)
- Triggered by tag push + release creation in UI/API

### Permissions

```yaml
permissions:
  contents: write
```

- Required to upload assets to the release

### Job: build-and-upload-deb

#### Step 1: Checkout

```yaml
- name: Checkout
  uses: actions/checkout@v4
```

#### Step 2: Prepare Package Metadata

```bash
TAG_NAME="${{ github.event.release.tag_name }}"
VERSION="${TAG_NAME#v}"

if [[ -z "${VERSION}" ]]; then
  echo "Failed to derive package version from release tag: ${TAG_NAME}" >&2
  exit 1
fi

echo "PACKAGE_NAME=image-optimiser" >> "$GITHUB_ENV"
echo "VERSION=${VERSION}" >> "$GITHUB_ENV"
echo "ITERATION=1" >> "$GITHUB_ENV"
echo "ARCH=all" >> "$GITHUB_ENV"
echo "DEB_FILENAME=image-optimiser_${VERSION}.deb" >> "$GITHUB_ENV"
echo "deb_filename=image-optimiser_${VERSION}.deb" >> "$GITHUB_OUTPUT"
```

- Extracts version from git tag (strips leading `v`)
- Validates version non-empty
- Sets environment variables for subsequent steps
- Outputs `deb_filename` for upload step

#### Step 3: Build Deb Package

```bash
PKG_ROOT="${{ github.workspace }}/pkg"
PKG_DIR="${PKG_ROOT}/${PACKAGE_NAME}_${VERSION}-${ITERATION}_${ARCH}"

rm -rf "${PKG_ROOT}"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/share/doc/${PACKAGE_NAME}"

printf '%s\n' \
  "Package: ${PACKAGE_NAME}" \
  "Version: ${VERSION}-${ITERATION}" \
  "Section: utils" \
  "Priority: optional" \
  "Architecture: ${ARCH}" \
  "Maintainer: Image Optimiser Maintainers <maintainers@example.com>" \
  "Depends: bash, coreutils, findutils, gawk, oxipng, jpegoptim" \
  "Description: Lossless CLI image optimiser for PNG and JPEG files" \
  " This package provides a command-line tool that recursively scans" \
  " directories and losslessly optimises PNG and JPEG images in place." \
  > "${PKG_DIR}/DEBIAN/control"

install -m 0755 "optimise-image.sh" "${PKG_DIR}/usr/bin/image-optimiser"
install -m 0644 "README.md" "${PKG_DIR}/usr/share/doc/${PACKAGE_NAME}/README.md"
install -m 0644 "LICENSE" "${PKG_DIR}/usr/share/doc/${PACKAGE_NAME}/copyright"

dpkg-deb --build --root-owner-group "${PKG_DIR}" "${DEB_FILENAME}"
ls -lh "${DEB_FILENAME}"
```

**Key differences from build-deb.sh:**
| Aspect | Workflow | build-deb.sh |
|--------|----------|--------------|
| Install path | `/usr/bin` | `/usr/local/bin` |
| Version format | `VERSION-ITERATION` (e.g., `1.0.0-1`) | `VERSION` only |
| Dependencies | `bash, coreutils, findutils, gawk, oxipng, jpegoptim` | `zopfli, jpegoptim` |
| Documentation | README.md + LICENSE in `/usr/share/doc` | AppStream metainfo only |
| Maintainer | Placeholder email | GitHub URL |

#### Step 4: Upload to Release

```yaml
- name: Upload deb to release assets
  uses: softprops/action-gh-release@v2
  with:
    files: ${{ steps.metadata.outputs.deb_filename }}
    overwrite_files: true
```

- Uploads built .deb as release asset
- `overwrite_files: true` allows re-uploading if release is re-published

## Release Process

1. Create and push a version tag: `git tag v1.0.0 && git push origin v1.0.0`
2. Create GitHub Release from tag (via UI or `gh release create`)
3. Workflow triggers automatically
4. .deb built and uploaded to release assets
5. Users download from release page

## Versioning

- Tags must follow `v<semver>` format (e.g., `v1.0.0`, `v2.3.1`)
- Version derived by stripping leading `v`
- Debian package version: `<semver>-1` (ITERATION=1)

## Potential Improvements

1. **Add ShellCheck for src/**: Change `shellcheck *.sh` to `shellcheck *.sh src/*.sh`
2. **Update checkout action**: Use `actions/checkout@v4` in bash.yml
3. **Add integration test**: Run script on test images in CI
4. **Align dependencies**: Ensure workflow and build-deb.sh declare consistent dependencies
5. **Add changelog generation**: Auto-generate from commits/PRs
6. **Sign packages**: Add GPG signing for .deb