[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/fund.html)
[![Latest Release](https://img.shields.io/github/v/release/hmlendea/image-optimiser)](https://github.com/hmlendea/image-optimiser/releases/latest)
[![Build Status](https://github.com/hmlendea/image-optimiser/actions/workflows/bash.yml/badge.svg)](https://github.com/hmlendea/image-optimiser/actions/workflows/bash.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://gnu.org/licenses/gpl-3.0)

# Image Optimiser

`image-optimiser` is a Linux shell utility that losslessly compresses image files in place.

It recursively scans one or more paths, optimises supported files, and prints per-file and total size reduction.

## Features

- Lossless optimisation for `PNG`, `JPG`, and `JPEG`
- Recursive directory scanning
- Multiple input paths in one run
- Keeps image metadata and file permissions where supported by the backend tools
- Reports before/after size for each file and for the full run

## How It Works

The script delegates optimisation to proven CLI tools:

- `PNG` -> `oxipng`
- `JPG/JPEG` -> `jpegoptim`

The files are edited in place, so no separate output folder is created.

## Requirements

- Linux
- Bash
- `find`, `awk`, `du`, `numfmt` (usually available in GNU coreutils/findutils)
- `oxipng`
- `jpegoptim`

### Install Dependencies

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y oxipng jpegoptim coreutils findutils gawk
```

Fedora:

```bash
sudo dnf install -y oxipng jpegoptim coreutils findutils gawk
```

Arch Linux:

```bash
sudo pacman -S --needed oxipng jpegoptim coreutils findutils gawk
```

## Usage

Make the script executable:

```bash
chmod +x optimise-image.sh
```

Run it with one or more files/directories:

```bash
./optimise-image.sh <path> [<path> ...]
```

Examples:

```bash
# Optimise all supported images in a directory tree
./optimise-image.sh ./assets

# Optimise files and directories together
./optimise-image.sh ./assets ./public/logo.png ./screenshots
```

## Output Example

```text
File #1: './assets/logo.png'
Size: 182K -> 156K

File #2: './assets/banner.jpg'
Size: 1.5M -> 1.3M

Finished processing 2 images
Size: 1.7M -> 1.4M
```

## Notes and Limitations

- Only `png`, `jpg`, and `jpeg` files are processed.
- Scanning is recursive for directory inputs.
- Non-existent paths are skipped with an error message.
- Compression is lossless, but always keep backups for critical assets.

## Troubleshooting

`oxipng: command not found` or `jpegoptim: command not found`

- Install missing dependencies from the Requirements section.

`Permission denied`

- Ensure the script is executable: `chmod +x optimise-image.sh`
- Ensure you have write permission for the target files.

No files processed

- Verify your path exists and contains `png`, `jpg`, or `jpeg` files.

## Contributing

Contributions are welcome.

Please:
- keep pull requests focused and consistent with the existing style.
- update documentation when behaviour changes.

## License

Licensed under the GNU General Public License v3.0 or later.
See [LICENSE](./LICENSE) for details.
