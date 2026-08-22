#!/usr/bin/env bash
set -euo pipefail

SWISS_COMMIT="3fd0f956d73898b91cc4f67cf18b21af656d1342"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SWISS_DIR="$REPO_ROOT/.forge/swisseph"
CORE_DIR="$REPO_ROOT/native/OrboCore"
OUTPUT_DIR="$REPO_ROOT/tools/pass5/orbospine-build/terra"

case "$(uname -s)" in
  Darwin) SWISS_LIBRARY="$SWISS_DIR/libswe.dylib" ;;
  Linux)  SWISS_LIBRARY="$SWISS_DIR/libswe.so" ;;
  *)
    echo "unsupported forge host: $(uname -s)" >&2
    exit 1
    ;;
esac

if [[ ! -d "$SWISS_DIR/.git" || ! -f "$SWISS_LIBRARY" ]]; then
  echo "missing pinned Swiss forge apparatus under .forge/swisseph" >&2
  echo "prepare it first with: bash tools/pass5/forge_orbospine_celestial.sh --prepare-only" >&2
  exit 1
fi

ACTUAL_COMMIT="$(git -C "$SWISS_DIR" rev-parse HEAD)"
if [[ "$ACTUAL_COMMIT" != "$SWISS_COMMIT" ]]; then
  echo "Swiss commit drift: $ACTUAL_COMMIT != $SWISS_COMMIT" >&2
  exit 1
fi

echo "ORBOSPINE FORGE / TERRA MARROW"
echo "Swiss commit: $SWISS_COMMIT"
echo "Swiss library: $SWISS_LIBRARY"
echo "output: $OUTPUT_DIR"

echo "build release Terra forge"
pushd "$CORE_DIR" >/dev/null
swift build -c release --product OrboSpineTerraForgeTool
BIN_DIR="$(swift build -c release --show-bin-path)"
popd >/dev/null

FORGE_TOOL="$BIN_DIR/OrboSpineTerraForgeTool"
if [[ ! -x "$FORGE_TOOL" ]]; then
  echo "release Terra forge tool not found: $FORGE_TOOL" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

"$FORGE_TOOL" \
  --library "$SWISS_LIBRARY" \
  --output-dir "$OUTPUT_DIR"
