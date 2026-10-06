[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![Latest Release](https://img.shields.io/github/v/release/hmlendea/image-optimiser)](https://github.com/hmlendea/image-optimiser/releases/latest)
[![Build Status](https://github.com/hmlendea/image-optimiser/actions/workflows/bash.yml/badge.svg)](https://github.com/hmlendea/image-optimiser/actions/workflows/bash.yml)
[![License](https://img.shields.io/github/license/hmlendea/image-optimiser)](https://github.com/hmlendea/image-optimiser/blob/master/LICENSE)

# Image Optimiser

`image-optimiser` is a Linux shell utility that losslessly compresses image files in place. It recursively scans one or more paths, optimises supported files using external CLI tools, and prints per-file and total size reduction.

## 📑 Table of Contents

- [Capabilities](#-capabilities)
- [Usage](#-usage)
- [Known Limitations](#-known-limitations)
- [System Requirements](#-system-requirements)
- [Installation](#-installation)
- [Compatibility](#-compatibility)
- [Privacy and Data](#-privacy-and-data)
- [Development](#-development)
- [GitHub Actions](#-github-actions)
- [Project Structure](#-project-structure)
- [Architecture](#-architecture)
- [Documentation](#-documentation)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [Security](#-security)
- [Project Engagement](#-project-engagement)
- [License](#-license)

## ✨ Capabilities

- Lossless optimisation for PNG, JPG, and JPEG files
- Recursive directory scanning with multiple input paths
- In-place file modification with size reporting
- Automatic tool selection (oxipng preferred, zopflipng fallback for PNG)
- Metadata and permission preservation where supported

## 🚀 Usage

Make the script executable and run with one or more paths:

```bash
chmod +x src/optimise-image.sh
./src/optimise-image.sh ./photos ./screenshots/logo.png
```

Output example:

```text
File #1: './photos/vacation.png'
Size: 2.1M -> 1.8M

File #2: './screenshots/logo.png'
Size: 3.4M -> 2.9M

Finished processing 2 images
Size: 5.5M -> 4.7M
```

## ⚠️ Known Limitations

- Only PNG, JPG, and JPEG files are processed
- Scanning is recursive for directory inputs
- Non-existent paths are skipped with an error message
- Compression is lossless but in-place; always keep backups for critical assets
- No configuration file; all behaviour controlled via CLI arguments
- Sequential processing only; no parallel execution
- Linux only; requires GNU coreutils and findutils

## 🖥️ System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | Linux (any distribution) | Linux with GNU coreutils/findutils |
| Shell | Bash 4.0+ | Bash 5.0+ |
| Runtime tools | `find`, `awk`, `du`, `numfmt` | GNU coreutils 8.22+, findutils 4.4+, gawk 4.0+ |
| PNG optimiser | `oxipng` or `zopflipng` | `oxipng` (preferred) |
| JPEG optimiser | `jpegoptim` | `jpegoptim` |

## 📦 Installation

[![Obtain it from GitHub](https://raw.githubusercontent.com/hmlendea/readme-assets/master/badges/stores/github.png)](https://github.com/hmlendea/image-optimiser/releases)

### Package Manager Installation

#### Debian/Ubuntu

```bash
sudo apt update
sudo apt install -y oxipng jpegoptim coreutils findutils gawk
```

#### Arch Linux

```bash
sudo pacman -S --needed oxipng jpegoptim coreutils findutils gawk
```

#### Fedora

```bash
sudo dnf install -y oxipng jpegoptim coreutils findutils gawk
```

### Manual Installation

Download the script directly:

```bash
curl -O https://raw.githubusercontent.com/hmlendea/image-optimiser/master/src/optimise-image.sh
chmod +x optimise-image.sh
```

### Installation from Source

```bash
git clone https://github.com/hmlendea/image-optimiser
cd image-optimiser
./build-deb.sh 1.0.0
sudo dpkg -i image-optimiser_1.0.0_all.deb
```

### Verification

```bash
./src/optimise-image.sh --help 2>&1 | head -1
# Expected: shows usage or processes a test file
```

## 🧩 Compatibility

| Component | Supported Versions | Notes |
|-----------|--------------------|-------|
| Linux kernel | Any modern version | Requires standard syscalls |
| Bash | 4.0+ | Tested on 5.0+ |
| oxipng | Any | `-o max --preserve --alpha` flags stable |
| zopflipng | Any | `-y -m` flags stable (fallback) |
| jpegoptim | Any | All used flags stable |
| GNU coreutils | 8.22+ | Required for `numfmt --to=iec` |
| GNU findutils | 4.4+ | Required for `find -print0` |
| GNU awk | 4.0+ | Standard features used |

## 🛡️ Privacy and Data

This project does not collect, process, transmit, or persist any user data, analytics, diagnostics, or telemetry. All processing occurs locally on the user's machine. No network connections are made.

## 🛠️ Development

### Requirements

- Bash 4.0+
- ShellCheck (for linting)
- `oxipng`, `jpegoptim`, `zopfli` (for testing)
- `dpkg-deb` (for building .deb package)

### Setup

```bash
git clone https://github.com/hmlendea/image-optimiser
cd image-optimiser
# Install dependencies for testing
sudo apt update && sudo apt install -y oxipng jpegoptim zopfli shellcheck
```

### Build

```bash
# Build Debian package
./build-deb.sh <version>
# Example: ./build-deb.sh 1.0.0
```

### Run

```bash
# Direct execution
./src/optimise-image.sh <path> [<path> ...]

# Or after installing .deb
image-optimiser <path> [<path> ...]
```

### Test

No automated test suite exists. Manual verification:

```bash
# Create test images and run
mkdir -p test-images
# Add PNG/JPG files to test-images
./src/optimise-image.sh test-images
```

### Linting

```bash
shellcheck src/optimise-image.sh build-deb.sh
```

### Continuous Integration

CI runs ShellCheck on push/PR to master:

```bash
# Reproduce locally
shellcheck *.sh src/*.sh --severity error
```

### Release

Releases are automated via GitHub Actions on tag push:

```bash
git tag v1.0.0
git push origin v1.0.0
# Then create GitHub Release from tag
```

The workflow builds a .deb package and uploads it as a release asset.

### Dependencies

| Package | Version | Scope | Purpose |
|---------|---------|-------|---------|
| oxipng | Any | Runtime | Primary PNG optimiser |
| zopfli | Any | Runtime | Fallback PNG optimiser (provides zopflipng) |
| jpegoptim | Any | Runtime | JPEG optimiser |
| coreutils | 8.22+ | Runtime | `du`, `numfmt` |
| findutils | 4.4+ | Runtime | `find -print0` |
| gawk | 4.0+ | Runtime | `awk` for size extraction |
| shellcheck | Latest | Development | Static analysis |
| dpkg-deb | Any | Build | Debian package creation |

## ⚙️ GitHub Actions

| Workflow | Purpose | What it does |
|----------|---------|--------------|
| [ Bash ](https://github.com/hmlendea/image-optimiser/blob/master/.github/workflows/bash.yml) | CI validation | Runs ShellCheck on all shell scripts with error severity |
| [ Release Debian Package ](https://github.com/hmlendea/image-optimiser/blob/master/.github/workflows/release-deb.yml) | Release automation | Builds .deb package on GitHub Release publish and uploads as asset |

## 🗂️ Project Structure

### Directories

| Directory | Purpose |
|-----------|---------|
| `src/` | Main script (`optimise-image.sh`) |
| `docs/` | Technical documentation |
| `.github/workflows/` | CI/CD workflows |

## 🏗️ Architecture

See the [architecture documentation](ARCHITECTURE.md) for the system context, principal components, runtime flows, ownership boundaries, dependencies, constraints, and extension points.

## 📚 Documentation

| Resource | Description |
|----------|-------------|
| [docs/overview.md](docs/overview.md) | Repository purpose, architecture, components, design decisions |
| [docs/usage.md](docs/usage.md) | Installation, usage, troubleshooting, limitations |
| [docs/main-script.md](docs/main-script.md) | Detailed main script implementation |
| [docs/build-packaging.md](docs/build-packaging.md) | Build script and Debian packaging |
| [docs/dependencies.md](docs/dependencies.md) | External tool dependencies |
| [docs/ci-cd.md](docs/ci-cd.md) | CI/CD pipeline details |
| [docs/security.md](docs/security.md) | Threat model and security considerations |
| [docs/testing.md](docs/testing.md) | Testing procedures and recommendations |

## 🩺 Troubleshooting

| Symptom | Probable Cause | Resolution |
|---------|----------------|------------|
| `oxipng: command not found` | oxipng not installed | Install oxipng or zopfli (provides zopflipng) |
| `jpegoptim: command not found` | jpegoptim not installed | Install jpegoptim |
| `numfmt: command not found` | coreutils too old or missing | Install/update coreutils (8.22+) |
| Permission denied | File/directory not writable | Check permissions; run with appropriate access |
| No files processed | Path empty or no matching extensions | Verify path exists and contains PNG/JPG/JPEG files |
| Script hangs on large file | Processing time proportional to size | Wait or check disk space |

## 🤝 Contributing

You are welcome to submit any suggestion, feedback, or modification to this project.

When doing so, please:
- Maintain cross-platform compatibility
- Submit focused pull requests that conform to the existing code style
- Maintain your branch synchronised with `master`
- Revise the documentation when functionality changes
- Properly test all modifications, including edge cases and error conditions
- Raise a new [issue](https://github.com/hmlendea/image-optimiser/issues) for problems or suggestions

## 🔒 Security

For information on reporting security vulnerabilities, see [SECURITY.md](SECURITY.md).

## 💝 Project Engagement

Discovered a problem or have a suggestion? [Open an issue](https://github.com/hmlendea/image-optimiser/issues)!

If you find this project useful, consider [funding it](https://hmlendea.go.ro/funding) or starring ⭐️ it on GitHub!

[![Donate](https://raw.githubusercontent.com/hmlendea/readme-assets/master/donate_generic.png)](https://hmlendea.go.ro/funding)

## 📄 License

This project is being distributed under the `GNU General Public License v3.0` or later.
See [LICENSE](LICENSE) for further information.
