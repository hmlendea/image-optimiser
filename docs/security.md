# Security Considerations

## Threat Model

`image-optimiser` is a local CLI tool that processes user-specified image files. The primary security considerations are:

1. **File system access** - Reads and writes files in user-specified paths
2. **External tool invocation** - Executes compression binaries with user-controlled file paths
3. **No network access** - No network operations, no data exfiltration
4. **No privilege escalation** - Runs with user privileges, no setuid/setgid

## Attack Surface

### Input Vectors

| Vector | Risk | Mitigation |
|--------|------|------------|
| Command-line arguments (paths) | Path traversal, injection | `find` with `-print0`, no shell interpolation of paths |
| File contents (images) | Parser exploits in tools | Delegated to mature tools (oxipng, jpegoptim) |
| Environment variables | Tool PATH manipulation | Uses `command -v` (PATH-only), no direct env usage |

### Path Handling Safety

```bash
# Safe: null-delimited find output, read with -d ''
while IFS= read -r -d '' IMAGE_PATH; do
    # IMAGE_PATH used directly, no eval, no interpolation
    oxipng ... "${IMAGE_PATH}"
done < <(find "${INPUT_PATH}" ... -print0)
```

**Protections:**
- `find -print0` + `read -d ''` handles all filenames (spaces, newlines, glob chars, Unicode)
- Variables quoted everywhere (`"${IMAGE_PATH}"`)
- No `eval`, no command substitution on user input
- No shell globbing on user paths

### Tool Invocation Safety

```bash
# Safe: arguments passed as array, no shell interpretation
oxipng -o max --preserve --alpha "${IMAGE_PATH}"
jpegoptim --preserve --preserve-perms --all-progressive -o --strip-all "${IMAGE_PATH}"
```

**Protections:**
- Tools invoked with explicit arguments, not shell command strings
- File path is final argument, no flag injection possible
- `command -v` validates tool existence before invocation

## Vulnerability Categories

### In Scope (Project Responsibility)

1. **Path traversal via arguments** - Mitigated by `find` operating within given path
2. **Argument injection** - Mitigated by quoted variable expansion
3. **Symlink following** - `find` follows symlinks by default; could process files outside intended tree
4. **TOCTOU (Time-of-check-time-of-use)** - File checked for existence, then processed; could be replaced
5. **Resource exhaustion** - Large files/deep trees could consume disk/memory

### Out of Scope (External Responsibility)

1. **Vulnerabilities in oxipng/zopflipng/jpegoptim** - Upstream responsibility
2. **Vulnerabilities in GNU coreutils/findutils** - Upstream responsibility
3. **Kernel/filesystem vulnerabilities** - OS responsibility
4. **Supply chain attacks on dependencies** - Distribution responsibility

## Symlink Consideration

Current behaviour: `find` follows symlinks by default.

```bash
# Current: follows symlinks
find "${INPUT_PATH}" -type f ...

# Alternative: don't follow symlinks
find "${INPUT_PATH}" -type f -xtype f ...
```

**Risk:** User runs `image-optimiser /home/user/images` where `/home/user/images/link` → `/etc/shadow`. Script would attempt to optimise `/etc/shadow` (fail on format, but still accesses).

**Mitigation options:**
- Add `-xtype f` to only process regular files (not symlinks to regular files)
- Document behaviour clearly
- Add `--no-follow` flag

## TOCTOU Window

```bash
if [[ ! -e "${INPUT_PATH}" ]]; then  # CHECK
    continue
fi
# ... later ...
find "${INPUT_PATH}" ...  # USE
```

**Risk:** Path replaced between check and use (unlikely for directories, possible for files).

**Impact:** Low - would process whatever replaced it, same permissions.

## Resource Exhaustion

| Resource | Scenario | Impact |
|----------|----------|--------|
| Disk I/O | Millions of large images | Slow, fills disk temporarily |
| Memory | `find` output buffer | Minimal (streaming) |
| CPU | Deep recursion, large files | Expected load |
| File descriptors | `find` + tools | Minimal |

**No hard limits** implemented. User controls input scope.

## Secure Usage Recommendations

1. **Run as non-root** - Never run with elevated privileges
2. **Verify backups** - In-place modification; keep backups of critical assets
3. **Limit input scope** - Don't run on `/` or system directories
4. **Audit symlinks** - Be aware of symlinks in input tree
5. **Validate tools** - Ensure `oxipng`/`jpegoptim` from trusted sources

## Hardening Opportunities

| Improvement | Effort | Impact |
|-------------|--------|--------|
| Add `-xtype f` to find | Low | Prevents symlink traversal |
| Add `--no-follow` flag | Low | User control over symlinks |
| Validate file type before processing | Medium | Defence in depth |
| Add file size limits | Medium | Prevent resource exhaustion |
| Checksum verification | High | Detect corruption |

## Security Policy Reference

See [SECURITY.md](../SECURITY.md) for:
- Supported versions
- Vulnerability reporting process
- Disclosure policy
- Safe harbour statement
- Recognition policy