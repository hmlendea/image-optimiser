# Usage Guide

## Installation

### Direct Script Usage

```bash
# Download
curl -O https://raw.githubusercontent.com/hmlendea/image-optimiser/master/src/optimise-image.sh
chmod +x optimise-image.sh

# Install dependencies (Debian/Ubuntu)
sudo apt update && sudo apt install -y oxipng jpegoptim coreutils findutils gawk

# Run
./optimise-image.sh ./photos
```

### Debian Package

```bash
# Download .deb from GitHub Releases
wget https://github.com/hmlendea/image-optimiser/releases/download/v1.0.0/image-optimiser_1.0.0_all.deb

# Install
sudo dpkg -i image-optimiser_1.0.0_all.deb

# Run (installed to /usr/local/bin)
image-optimiser ./photos
```

### Build from Source

```bash
git clone https://github.com/hmlendea/image-optimiser
cd image-optimiser
./build-deb.sh 1.0.0
sudo dpkg -i image-optimiser_1.0.0_all.deb
```

## Basic Usage

```bash
# Single directory
image-optimiser ./photos

# Multiple directories and files
image-optimiser ./photos ./screenshots ./logo.png

# Current directory
image-optimiser .
```

## Output Interpretation

```
File #1: './photos/vacation.png'
Size: 2.1M -> 1.8M

File #2: './photos/portrait.jpg'
Size: 3.4M -> 2.9M

Finished processing 2 images
Size: 5.5M -> 4.7M
```

- **Per-file lines**: Original size → Optimised size (human-readable)
- **Summary**: Total count, total original → total final
- **Reduction**: Implicit (original - final)

## Supported Formats

| Extension | Tool | Lossless |
|-----------|------|----------|
| `.png` | oxipng (preferred) / zopflipng | Yes |
| `.jpg` | jpegoptim | Yes |
| `.jpeg` | jpegoptim | Yes |

Case-insensitive: `.PNG`, `.JPG`, `.Jpeg` all work.

## Advanced Usage

### Dry Run (Preview Only)

Not directly supported. Workaround:

```bash
# Copy files first, run on copy
cp -r photos photos-backup
image-optimiser photos-backup
# Compare sizes
du -sh photos photos-backup
```

### Exclude Patterns

Not directly supported. Workaround:

```bash
# Use find to filter, then pass files explicitly
find photos -type f \( -iname '*.png' -o -iname '*.jpg' \) ! -name 'thumb-*' -print0 | xargs -0 image-optimiser
```

### Parallel Processing

Not supported (sequential by design). For parallelism:

```bash
# Split directories, run multiple instances
image-optimiser dir1 &
image-optimiser dir2 &
wait
```

### Preserve Originals

Not supported (in-place only). Always backup first:

```bash
cp -r photos photos-backup
image-optimiser photos
```

## Environment Variables

None used. All configuration via CLI arguments.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (even if some paths missing) |
| Non-zero | Shell error (syntax, permission, etc.) |

Individual file failures don't affect exit code.

## Common Workflows

### Website Asset Optimisation

```bash
# Optimise all images in web project
image-optimiser public/assets images uploads
```

### Photo Archive Maintenance

```bash
# Yearly optimisation of photo library
image-optimiser ~/Pictures/2023 ~/Pictures/2024
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Optimise images
  run: |
    sudo apt-get update && sudo apt-get install -y oxipng jpegoptim
    ./optimise-image.sh ./src/assets
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `oxipng: command not found` | Install oxipng or zopfli (provides zopflipng) |
| `jpegoptim: command not found` | Install jpegoptim |
| `numfmt: command not found` | Install coreutils (usually present) |
| Permission denied | Check file/directory permissions |
| No size reduction | Image already optimal; try different tool |
| Script hangs | Large file; wait or check disk space |

## Limitations

- **In-place only**: No output directory option
- **No config file**: All options via CLI
- **No progress bar**: Only per-file output
- **No undo**: Backup before running
- **Sequential**: No parallel processing
- **Linux only**: Requires GNU coreutils/findutils

## Tips

1. **Always backup** critical images before optimising
2. **Run on copies** first to verify results
3. **Check tool versions** for best compression: `oxipng --version`, `jpegoptim --version`
4. **Monitor disk space** during large batch operations
5. **Use SSD** for faster I/O on large collections