# qon-build

Official build and distribution repository for Qon.

This repository is responsible for:

- Building the Qon CLI binary for all supported platforms.
- Publishing platform-specific npm packages under `@qonjs/*`.
- Creating GitHub releases containing compiled binaries.
- Running the automation pipeline for build and distribution.

This repository is build automation only and does not accept external contributions.

## Versioning

The single source of truth is `core/VERSION`.

Rules:

- No version is defined in this repository outside `core/VERSION`.
- The same value is used for:
	- npm package versions
	- GitHub release tag (`v<VERSION>`)
	- binary build metadata

Example:

`core/VERSION` = `1.2.0`

- `@qonjs/linux-x64@1.2.0`
- Release tag: `v1.2.0`
- Binary assets labeled `1.2.0`

## Supported npm Packages

The pipeline generates and publishes:

- `@qonjs/win32-x64`
- `@qonjs/win32-arm64`
- `@qonjs/win32-ia32`
- `@qonjs/linux-x64`
- `@qonjs/linux-arm64`
- `@qonjs/linux-arm`
- `@qonjs/darwin-x64`
- `@qonjs/darwin-arm64`

## Repository Structure

```text
qon-build/
	core/                     # Qon core submodule (contains VERSION)
	scripts/                  # Build/package/publish scripts
	.github/workflows/        # CI/CD workflow
	dist/                     # Generated binaries (gitignored)
	packages/                 # Generated npm packages (gitignored)
```

## Pipeline Overview

Workflow file: `.github/workflows/build.yml`

Triggers:

- Manual: `workflow_dispatch`
- Tag push: `v*.*.*`

Steps:

1. Sync latest `core` submodule.
2. Read version from `core/VERSION`.
3. Build binaries for all supported targets.
4. Generate per-platform npm packages.
5. Publish packages to npm using Trusted Publishing (OIDC).
6. Create a GitHub release and upload binary assets.

## Local Script Usage

```bash
# Resolve version from core/VERSION
scripts/resolve-version.sh core/VERSION

# Build all binaries into dist/
scripts/build-binaries.sh dist

# Generate npm packages into packages/
scripts/package-npm.sh dist packages

# Publish all generated packages
scripts/publish-npm.sh packages
```

## npm Distribution Model

Each package contains:

- `bin/qon` or `bin/qon.exe`
- `package.json` with `os`/`cpu` constraints

This allows `qon-js` to consume platform binaries via `optionalDependencies`.

## Security

- npm Trusted Publishing (OIDC)
- No long-lived npm tokens required in this repository
- Public workflow and scripts for full transparency

## Repository Policy

- No external contributions
- Build automation only
