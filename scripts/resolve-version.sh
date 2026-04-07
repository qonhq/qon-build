#!/usr/bin/env bash
set -euo pipefail

VERSION_FILE="${1:-core/VERSION}"

if [[ -n "${QON_VERSION:-}" ]]; then
  VERSION="${QON_VERSION#v}"
else
  if [[ ! -f "$VERSION_FILE" ]]; then
    echo "VERSION file not found: $VERSION_FILE" >&2
    exit 1
  fi

  VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
fi

VERSION="${VERSION#v}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.-]+)?$ ]]; then
  echo "Invalid semantic version in $VERSION_FILE: $VERSION" >&2
  exit 1
fi

echo "$VERSION"
