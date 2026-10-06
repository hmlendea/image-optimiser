# Documentation Index

## Overview Documents

| Document | Description |
|----------|-------------|
| [overview.md](overview.md) | Repository purpose, architecture, components, design decisions |
| [usage.md](usage.md) | Installation, basic/advanced usage, troubleshooting, limitations |

## Implementation Documents

| Document | Description |
|----------|-------------|
| [main-script.md](main-script.md) | Detailed `src/optimise-image.sh` implementation, flow, variables, error handling |
| [build-packaging.md](build-packaging.md) | `build-deb.sh` implementation, Debian package structure, AppStream metadata |
| [dependencies.md](dependencies.md) | External tool dependencies, invocation details, installation, version compatibility |
| [ci-cd.md](ci-cd.md) | GitHub Actions workflows: ShellCheck validation, release automation |

## Quality & Security Documents

| Document | Description |
|----------|-------------|
| [security.md](security.md) | Threat model, attack surface, vulnerability categories, hardening opportunities |
| [testing.md](testing.md) | Current test state, manual procedures, recommended automated structure, coverage goals |

## Root-Level Documents

| Document | Location | Description |
|----------|----------|-------------|
| README.md | `/` | Project overview, features, requirements, usage examples |
| ARCHITECTURE.md | `/` | Architecture overview, components, data flow, design decisions |
| SECURITY.md | `/` | Security policy, supported versions, vulnerability reporting |
| LICENSE | `/` | GPL-3.0 license text |
| ROADMAP.md | `/` | (Not yet created) Future plans and milestones |
| PRIVACY.md | `/` | (Not yet created) Data handling policy |

## Quick Navigation

### For Users
1. Start with [README.md](../README.md) for overview
2. See [usage.md](usage.md) for installation and usage
3. Check [SECURITY.md](../SECURITY.md) for security policy

### For Contributors
1. Read [overview.md](overview.md) for architecture
2. Study [main-script.md](main-script.md) for core logic
3. Review [build-packaging.md](build-packaging.md) for packaging
4. See [ci-cd.md](ci-cd.md) for CI/CD pipelines
5. Check [testing.md](testing.md) for test procedures
6. Review [security.md](security.md) for security considerations

### For Packagers
1. See [build-packaging.md](build-packaging.md) for .deb creation
2. Review [dependencies.md](dependencies.md) for dependency declarations
3. Check [ci-cd.md](ci-cd.md) for release automation

### For Security Researchers
1. Read [SECURITY.md](../SECURITY.md) for reporting process
2. Review [security.md](security.md) for threat model and attack surface
3. See [dependencies.md](dependencies.md) for supply chain considerations

## Documentation Maintenance

- Update relevant docs when modifying implementation
- Keep root-level docs (README, ARCHITECTURE, SECURITY) as primary references
- `docs/` contains detailed technical documentation
- Cross-reference between documents where relevant