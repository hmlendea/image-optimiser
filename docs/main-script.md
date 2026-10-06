# Main Script Implementation - src/optimise-image.sh

## Purpose

The main script implements the complete image optimisation pipeline: recursive file discovery, format detection, tool dispatch, in-place optimisation, and size reporting.

## Entry Point

```bash
./optimise-image.sh <path> [<path> ...]
```

- Accepts one or more file/directory paths as positional arguments
- Each path is processed independently
- Non-existent paths are skipped with an error message

## Execution Flow

### 1. Argument Processing

```bash
for INPUT_PATH in "${@}"; do
    if [[ ! -e "${INPUT_PATH}" ]]; then
        echo "The '${INPUT_PATH}' path does not exist."
        continue
    fi
    # ... process path
done
```

- Iterates over all positional arguments
- Validates existence with `-e` (file or directory)
- Continues to next path on failure (non-fatal)

### 2. Recursive File Discovery

```bash
while IFS= read -r -d '' IMAGE_PATH; do
    [ ! -f "${IMAGE_PATH}" ] && continue
    # ... process file
done < <(find "${INPUT_PATH}" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0)
```

- Uses `find` with `-print0` and `read -d ''` for null-delimited output (handles spaces, newlines, special chars)
- Filters by extension case-insensitively (`-iname`)
- Only processes regular files (`-type f`)
- Skips non-files defensively (`[ ! -f ... ] && continue`)

### 3. Format Detection

```bash
IMAGE_EXTENSION="${IMAGE_PATH##*.}"
IMAGE_EXTENSION="${IMAGE_EXTENSION,,}"
```

- Extracts extension after last `.` using parameter expansion
- Converts to lowercase with `,,` for case-insensitive matching

### 4. Size Measurement (Pre-Optimisation)

```bash
IMAGE_SIZE_ORIGINAL=$(du -b "${IMAGE_PATH}" | awk '{print $1}')
TOTAL_SIZE_ORIGINAL=$((TOTAL_SIZE_ORIGINAL+IMAGE_SIZE_ORIGINAL))
```

- Uses `du -b` for exact byte count (not block count)
- `awk '{print $1}'` extracts size from `du` output
- Accumulates to running total

### 5. Tool Dispatch & Optimisation

#### PNG Path

```bash
if [[ "${IMAGE_EXTENSION}" == "png" ]]; then
    if command -v oxipng &>/dev/null; then
        oxipng -o max --preserve --alpha "${IMAGE_PATH}"
    else
        zopflipng -y -m "${IMAGE_PATH}" "${IMAGE_PATH}"
    fi
```

**Primary: oxipng**
- `-o max` - Maximum optimisation level
- `--preserve` - Preserve file metadata (timestamps, etc.)
- `--alpha` - Preserve alpha channel

**Fallback: zopflipng**
- `-y` - Overwrite output file
- `-m` - Maximum compression
- Takes input and output paths (same for in-place)

#### JPEG Path

```bash
elif [[ "${IMAGE_EXTENSION}" == "jpg" ]] \
  || [[ "${IMAGE_EXTENSION}" == "jpeg" ]]; then
    jpegoptim --preserve --preserve-perms --all-progressive -o --strip-all "${IMAGE_PATH}"
```

**jpegoptim options:**
- `--preserve` - Preserve timestamps
- `--preserve-perms` - Preserve file permissions
- `--all-progressive` - Convert to progressive JPEG
- `-o` - Overwrite original file
- `--strip-all` - Strip all markers (EXIF, ICC, etc.)

### 6. Size Measurement (Post-Optimisation)

```bash
IMAGE_SIZE_FINAL=$(du -b "${IMAGE_PATH}" | awk '{print $1}')
TOTAL_SIZE_FINAL=$((TOTAL_SIZE_FINAL+IMAGE_SIZE_FINAL))
```

- Same measurement approach as pre-optimisation
- Accumulates to running total

### 7. Per-File Reporting

```bash
echo "File #${IMAGES_COUNT}: '${IMAGE_PATH}'"
echo "Size: $(numfmt --to=iec <<< ${IMAGE_SIZE_ORIGINAL}) -> $(numfmt --to=iec <<< ${IMAGE_SIZE_FINAL})"
echo ""
```

- `numfmt --to=iec` converts bytes to human-readable (KiB, MiB, etc.)
- Uses here-string `<<<` for input

### 8. Summary Reporting

```bash
echo "Finished processing ${IMAGES_COUNT} images"
echo "Size: $(numfmt --to=iec <<< ${TOTAL_SIZE_ORIGINAL}) -> $(numfmt --to=iec <<< ${TOTAL_SIZE_FINAL})"
```

## State Variables

| Variable | Purpose |
|----------|---------|
| `IMAGES_COUNT` | Total files processed |
| `TOTAL_SIZE_ORIGINAL` | Sum of original byte sizes |
| `TOTAL_SIZE_FINAL` | Sum of optimised byte sizes |
| `IMAGE_PATH` | Current file being processed |
| `IMAGE_EXTENSION` | Lowercase file extension |
| `IMAGE_SIZE_ORIGINAL` | Current file original size (bytes) |
| `IMAGE_SIZE_FINAL` | Current file optimised size (bytes) |

## Error Handling

| Scenario | Behaviour |
|----------|-----------|
| Path doesn't exist | Print error, continue to next path |
| Unsupported extension | Print error, continue to next file |
| `oxipng` not found | Fall back to `zopflipng` |
| `zopflipng` not found | Implicit failure (command not found) |
| `jpegoptim` not found | Implicit failure (command not found) |
| Optimisation tool fails | Non-zero exit propagates (script continues) |

## Invariants

1. **File count accuracy**: `IMAGES_COUNT` increments only for successfully processed files
2. **Size accumulation**: Totals only include files that completed optimisation
3. **In-place modification**: Original file is always overwritten
4. **Lossless guarantee**: All tools invoked with lossless-preserving flags
5. **Null-safe iteration**: `find -print0` + `read -d ''` handles all filenames

## Testing Considerations

- No automated tests exist in repository
- Manual verification: run on test directory with known images
- Check: file sizes decrease, no corruption, metadata preserved where expected
- Edge cases: spaces in filenames, nested directories, mixed case extensions, missing tools