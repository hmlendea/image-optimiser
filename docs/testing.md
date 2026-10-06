# Testing Guide

## Current State

**No automated tests exist in the repository.**

The only CI validation is ShellCheck static analysis on `build-deb.sh` (not on `src/optimise-image.sh`).

## Manual Testing Procedures

### Basic Functionality Test

```bash
# Create test directory with sample images
mkdir -p test-images/subdir
# Add test PNG, JPG, JPEG files (any images)

# Run optimiser
./src/optimise-image.sh test-images

# Verify output shows processing and size reduction
# Verify files are actually smaller (ls -lh)
```

### Edge Case Tests

| Test Case | Command | Expected |
|-----------|---------|----------|
| Non-existent path | `./src/optimise-image.sh /nonexistent` | Error message, exit 0 |
| Empty directory | `./src/optimise-image.sh empty-dir` | "Finished processing 0 images" |
| Single file | `./src/optimise-image.sh test.png` | Processes one file |
| Multiple paths | `./src/optimise-image.sh dir1 dir2 file.jpg` | Processes all |
| Spaces in names | `./src/optimise-image.sh "my photos"` | Handles correctly |
| Mixed case extensions | `./src/optimise-image.sh test.PNG test.Jpg` | Processes all |
| Symlinks | `ln -s target.png link.png; ./src/optimise-image.sh link.png` | Follows symlink (current) |
| Missing oxipng | `PATH="" ./src/optimise-image.sh test.png` | Falls back to zopflipng |
| Missing jpegoptim | `PATH="" ./src/optimise-image.sh test.jpg` | Command not found error |
| Read-only file | `chmod 444 test.png; ./src/optimise-image.sh test.png` | Permission error |
| Large file | `./src/optimise-image.sh huge.png` | Processes (may be slow) |

### Regression Test Checklist

After any changes, verify:

- [ ] Script runs without syntax errors (`bash -n src/optimise-image.sh`)
- [ ] ShellCheck passes (`shellcheck src/optimise-image.sh`)
- [ ] PNG optimisation works (oxipng path)
- [ ] PNG fallback works (zopflipng path)
- [ ] JPEG optimisation works
- [ ] Recursive directory traversal works
- [ ] Size reporting accurate (compare `du -b` before/after)
- [ ] Multiple input paths work
- [ ] Non-existent paths handled gracefully
- [ ] Unsupported extensions skipped with message
- [ ] File permissions preserved (check with `stat`)
- [ ] Timestamps preserved (check with `stat`)
- [ ] Special characters in filenames handled

## Recommended Automated Test Structure

### Unit Tests (Bats or shunit2)

```bash
# test/unit.bats
@test "script rejects non-existent path" {
  run ./src/optimise-image.sh /nonexistent
  [ "$status" -eq 0 ]
  [[ "$output" =~ "does not exist" ]]
}

@test "script processes PNG with oxipng" {
  # Requires oxipng installed
  cp test/fixtures/sample.png /tmp/test.png
  run ./src/optimise-image.sh /tmp/test.png
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Finished processing 1 images" ]]
}

@test "script falls back to zopflipng when oxipng missing" {
  # Mock PATH without oxipng
  PATH="/usr/bin:/bin" run ./src/optimise-image.sh /tmp/test.png
  [ "$status" -eq 0 ]
}
```

### Integration Tests

```bash
# test/integration.bats
@test "end-to-end: directory with mixed formats" {
  # Setup test tree
  mkdir -p /tmp/test-tree/{sub1,sub2}
  cp test/fixtures/*.png /tmp/test-tree/
  cp test/fixtures/*.jpg /tmp/test-tree/sub1/

  run ./src/optimise-image.sh /tmp/test-tree
  [ "$status" -eq 0 ]
  # Verify all files processed
  [[ "$output" =~ "Finished processing 4 images" ]]
}
```

### Property-Based Tests

- File size never increases (lossless guarantee)
- Output file is valid image (magic bytes check)
- Metadata preserved where flags specify
- Idempotence: running twice produces same result

## Test Fixtures Needed

```
test/fixtures/
├── sample.png          # Standard PNG
├── sample.jpg          # Standard JPEG
├── sample.jpeg         # JPEG with .jpeg extension
├── transparent.png     # PNG with alpha
├── progressive.jpg     # Already progressive JPEG
├── with-exif.jpg       # JPEG with EXIF data
├── large.png           # >10MB PNG
├── tiny.png            # 1x1 pixel
└── unicode-文件名.png   # Unicode filename
```

## CI Integration

Add to `.github/workflows/bash.yml`:

```yaml
- name: Run tests
  run: |
    # Install test dependencies
    sudo apt-get update && sudo apt-get install -y bats
    # Run unit tests
    bats test/unit.bats
    # Run integration tests
    bats test/integration.bats
```

## Coverage Goals

| Area | Target |
|------|--------|
| Argument parsing | 100% |
| File discovery | 100% |
| Format detection | 100% |
| PNG path (oxipng) | 100% |
| PNG path (zopflipng) | 100% |
| JPEG path | 100% |
| Size reporting | 100% |
| Error paths | 90% |
| Edge cases | 80% |

## Performance Benchmarks

Track over time:

| Metric | Baseline | Target |
|--------|----------|--------|
| 100 PNGs (1MB each) | ~30s | <30s |
| 1000 JPEGs (500KB each) | ~45s | <45s |
| Memory usage | <50MB | <50MB |
| Disk temp usage | 0B | 0B |

## Future: Fuzzing

Consider `american-fuzzy-lop` or `libfuzzer` on:
- Malformed PNG/JPEG inputs
- Extremely long paths
- Deeply nested directories
- Filenames with special characters