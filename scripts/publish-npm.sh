#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="${1:-$REPO_ROOT/packages}"
NPM_TAG="${2:-latest}"

if [[ ! -d "$PACKAGES_DIR" ]]; then
  echo "Packages directory not found: $PACKAGES_DIR" >&2
  exit 1
fi

for package_dir in "$PACKAGES_DIR"/*; do
  [[ -d "$package_dir" ]] || continue
  echo "Publishing $(basename "$package_dir")"
  (
    cd "$package_dir"
    npm publish --access public --provenance --tag "$NPM_TAG"
  )
done

echo "Published packages from $PACKAGES_DIR with dist-tag '$NPM_TAG'"
