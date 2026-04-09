#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$($REPO_ROOT/scripts/resolve-version.sh "$REPO_ROOT/core/VERSION")"
DIST_DIR="${1:-$REPO_ROOT/dist}"
PACKAGES_DIR="${2:-$REPO_ROOT/packages}"

if [[ ! -d "$DIST_DIR" ]]; then
  echo "Dist directory not found: $DIST_DIR" >&2
  exit 1
fi

mkdir -p "$PACKAGES_DIR"

TARGETS=(
  "win32-x64 win32 x64 exe"
  "win32-arm64 win32 arm64 exe"
  "win32-ia32 win32 ia32 exe"
  "linux-x64 linux x64"
  "linux-arm64 linux arm64"
  "linux-arm linux arm"
  "darwin-x64 darwin x64"
  "darwin-arm64 darwin arm64"
)

for target in "${TARGETS[@]}"; do
  read -r package_name npm_os npm_cpu ext <<< "$target"
  package_path="$PACKAGES_DIR/$package_name"
  bin_path="$package_path/bin"

  rm -rf "$package_path"
  mkdir -p "$bin_path"

  src_bin="$DIST_DIR/qon-${package_name}${ext:+.$ext}"
  dst_bin="$bin_path/qon${ext:+.$ext}"

  if [[ ! -f "$src_bin" ]]; then
    echo "Missing binary for $package_name: $src_bin" >&2
    exit 1
  fi

  cp "$src_bin" "$dst_bin"
  chmod +x "$dst_bin" || true

  cat > "$package_path/package.json" <<JSON
{
  "name": "@qonjs/$package_name",
  "version": "$VERSION",
  "description": "Prebuilt Qon binary for $npm_os/$npm_cpu",
  "license": "MIT",
  "os": ["$npm_os"],
  "cpu": ["$npm_cpu"],
  "files": ["bin"],
  "main": "bin/qon${ext:+.$ext}",
  "bin": {
    "qon": "bin/qon${ext:+.$ext}"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/qonhq/qon-build.git"
  },
  "author": "Qon Team"
}
JSON

  cat > "$package_path/README.md" <<MD
# @qonjs/$package_name

This package provides the prebuilt Qon CLI binary for **$npm_os/$npm_cpu**.

It is published automatically by the \
[qon-build](https://github.com/qonhq/qon-build) release pipeline.
MD

done

echo "Generated npm packages in $PACKAGES_DIR"
