#!/bin/bash
set -e

VERSION="${1}"

if [[ -z "${VERSION}" ]]; then
    echo "Error: version parameter is required." >&2
    echo "Usage: $0 <version>" >&2
    exit 1
fi

PACKAGE_NAME="optimise-image"
ARCH="all"
BUILD_DIR="$(mktemp -d)"
DEB_ROOT="${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}_${ARCH}"

# Create directory structure
mkdir -p "${DEB_ROOT}/usr/local/bin"
mkdir -p "${DEB_ROOT}/DEBIAN"
mkdir -p "${DEB_ROOT}/usr/share/metainfo"

# Copy script
cp optimise-image.sh "${DEB_ROOT}/usr/local/bin/optimise-image"
chmod 755 "${DEB_ROOT}/usr/local/bin/optimise-image"

# Write AppStream metainfo (read by GNOME Software for license, description, etc.)
cat > "${DEB_ROOT}/usr/share/metainfo/io.github.hmlendea.${PACKAGE_NAME}.metainfo.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="console-application">
  <id>io.github.hmlendea.${PACKAGE_NAME}</id>
  <metadata_license>FSFAP</metadata_license>
  <project_license>GPL-3.0-only</project_license>
  <name>image-optimiser</name>
  <summary>Lossless image optimiser for PNG, JPG, and JPEG files</summary>
  <description>
    <p>
      A shell utility that losslessly compresses image files in place. It recursively scans one or more paths, optimises supported files using oxipng (PNG) and jpegoptim (JPG/JPEG), and reports per-file and total size reduction.
    </p>
  </description>
  <url type="homepage">https://github.com/hmlendea/image-optimiser</url>
</component>
EOF

# Write control file
cat > "${DEB_ROOT}/DEBIAN/control" <<EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Depends: oxipng, jpegoptim
Maintainer: hmlendea <https://github.com/hmlendea>
Homepage: https://github.com/hmlendea/image-optimiser
License: GPL-3.0
Description: Lossless image optimiser for PNG, JPG, and JPEG files.
 A shell utility that losslessly compresses image files in place. It recursively scans one or more paths, optimises supported files using oxipng (PNG) and jpegoptim (JPG/JPEG), and reports per-file and total size reduction.
EOF

# Build the .deb
dpkg-deb --build --root-owner-group "${DEB_ROOT}" "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"

rm -rf "${BUILD_DIR}"

echo "Built: ${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
