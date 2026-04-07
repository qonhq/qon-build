#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OUT_DIR_INPUT="${1:-dist}"
if [[ "$OUT_DIR_INPUT" = /* ]] || [[ "$OUT_DIR_INPUT" =~ ^[A-Za-z]:[\\/].* ]]; then
  OUT_DIR="$OUT_DIR_INPUT"
else
  OUT_DIR="$REPO_ROOT/$OUT_DIR_INPUT"
fi

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*

TARGETS=(
  "win32-x64 windows amd64 .exe"
  "win32-arm64 windows arm64 .exe"
  "win32-ia32 windows 386 .exe"
  "linux-x64 linux amd64"
  "linux-arm64 linux arm64"
  "linux-arm linux arm"
  "darwin-x64 darwin amd64"
  "darwin-arm64 darwin arm64"
)

for target in "${TARGETS[@]}"; do
  read -r package_name goos goarch ext <<< "$target"
  output="$OUT_DIR/qon-${package_name}${ext:-}"

  echo "Building $output"
  (
    cd "$REPO_ROOT/core"
    CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch" \
      go build -trimpath -ldflags "-s -w" -o "$output" ./cmd/qon
  )
done

echo "Built binaries in $OUT_DIR"
