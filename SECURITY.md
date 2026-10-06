# Security Policy

This document describes the security policy for `image-optimiser`, including supported versions, vulnerability reporting, scope, and disclosure expectations.

## 📑 Table of Contents

- Supported Versions
- Reporting a Vulnerability
- Scope
- Disclosure Policy
- Safe Harbour
- Recognition

## 🛡️ Supported Versions

Use this table to indicate which project versions currently receive security maintenance.

| Version | Distribution Channel | Supported |
|---------|--------------------|-----------|
| Latest version | GitHub Releases | ✅ |
| Latest version | Debian package (.deb) | ✅ |
| Preceding versions | Any distribution channel | ❌ |

## 🚨 Reporting a Vulnerability

Please do not disclose suspected vulnerabilities publicly before maintainers have had an opportunity to validate and remediate them.

To report a vulnerability:
- [GitHub Security Advisories](https://github.com/hmlendea/image-optimiser/security/advisories)
- Contact the maintainers directly

## 📌 Scope

The subsequent report categories are in scope for this repository:
- Image processing logic and file handling in `src/optimise-image.sh`
- External tool invocation and argument construction
- Recursive directory traversal and file discovery
- Size calculation and reporting accuracy
- Build and packaging scripts (`build-deb.sh`)

The subsequent categories are out of scope unless explicitly stated to the contrary:
- Vulnerabilities in external dependencies (`oxipng`, `jpegoptim`, `zopflipng`, `zopfli`)
- Operating system or filesystem vulnerabilities
- Issues in GNU coreutils (`find`, `awk`, `du`, `numfmt`)
- Supply-chain attacks on distribution channels

## 📢 Disclosure Policy

This project follows coordinated disclosure:
1. Vulnerabilities are investigated privately.
2. A remediation plan is prepared and validated.
3. Public disclosure is published after a fix, mitigation, or agreed risk decision is available.
4. Credit is attributed in accordance with reporter preference and project policy.

## 🧾 Safe Harbour

If your research is conducted in good faith, confined to authorised scope, and disclosed responsibly, the maintainers will not pursue action for policy-compliant activity.

## 🙏 Recognition

We appreciate responsible disclosure. Reporters who desire public attribution may be acknowledged in release notes, advisories, or a dedicated acknowledgements section.