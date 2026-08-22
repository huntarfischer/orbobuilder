#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CORE_DIR="$REPO_ROOT/native/OrboCore"
BUILD_ROOT="$REPO_ROOT/tools/pass5/orbospine-build"

if [[ ! -f "$BUILD_ROOT/terra/terra-marrow-manifest.json" ]]; then
  echo "missing Terra Marrow manifest: $BUILD_ROOT/terra/terra-marrow-manifest.json" >&2
  exit 1
fi

if [[ ! -f "$BUILD_ROOT/celestial/orbospine-celestial-manifest.json" ]]; then
  echo "missing celestial manifest: $BUILD_ROOT/celestial/orbospine-celestial-manifest.json" >&2
  exit 1
fi

cd "$CORE_DIR"

echo "ORBOSPINE C7 / GREEN GATE"
swift test

echo "ORBOSPINE C7 / FORGE MOTION BODY"
swift run -c release OrboSpineMotionForgeTool --build-root "$BUILD_ROOT"

echo "ORBOSPINE C7 / RE-CLOSE CANDIDATE"
swift run -c release OrboSpineCandidateManifestTool --build-root "$BUILD_ROOT"
