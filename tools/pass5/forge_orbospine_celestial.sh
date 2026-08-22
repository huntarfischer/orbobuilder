#!/usr/bin/env bash
set -euo pipefail

# Repo-local Pass C celestial manufacture.
#
# The repo owns this recipe. Disposable Swiss/DE441 apparatus lives under .forge/
# and manufactured celestial matter lives under tools/pass5/orbospine-build/.
# Neither is admitted to canonical runtime resources by this script.

SWISS_REPO="https://github.com/huntarfischer/swisseph.git"
SWISS_COMMIT="3fd0f956d73898b91cc4f67cf18b21af656d1342"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FORGE_ROOT="$REPO_ROOT/.forge"
SWISS_DIR="$FORGE_ROOT/swisseph"
EPHE_DIR="$FORGE_ROOT/ephe"
CORE_DIR="$REPO_ROOT/native/OrboCore"
OUTPUT_DIR="$REPO_ROOT/tools/pass5/orbospine-build/celestial"

PREPARE_ONLY=0
if [[ "${1:-}" == "--prepare-only" ]]; then
  PREPARE_ONLY=1
elif [[ $# -gt 0 ]]; then
  echo "usage: $0 [--prepare-only]" >&2
  exit 2
fi

for tool in git make swift grep; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "missing required tool: $tool" >&2
    exit 1
  fi
done

case "$(uname -s)" in
  Darwin)
    SWISS_LIBRARY_NAME="libswe.dylib"
    ;;
  Linux)
    SWISS_LIBRARY_NAME="libswe.so"
    ;;
  *)
    echo "unsupported forge host: $(uname -s)" >&2
    exit 1
    ;;
esac

REQUIRED_EPHE_FILES=(
  seplm36.se1 seplm30.se1 seplm24.se1 seplm18.se1 seplm12.se1 seplm06.se1
  sepl_00.se1 sepl_06.se1 sepl_12.se1 sepl_18.se1 sepl_24.se1
  semom36.se1 semom30.se1 semom24.se1 semom18.se1 semom12.se1 semom06.se1
  semo_00.se1 semo_06.se1 semo_12.se1 semo_18.se1 semo_24.se1
)

mkdir -p "$FORGE_ROOT" "$SWISS_DIR"

if [[ ! -d "$SWISS_DIR/.git" ]]; then
  git -C "$SWISS_DIR" init -q
fi

if git -C "$SWISS_DIR" remote get-url origin >/dev/null 2>&1; then
  git -C "$SWISS_DIR" remote set-url origin "$SWISS_REPO"
else
  git -C "$SWISS_DIR" remote add origin "$SWISS_REPO"
fi

echo "ORBOSPINE FORGE PREP / PINNED SWISS"
echo "repo: $SWISS_REPO"
echo "commit: $SWISS_COMMIT"

git -C "$SWISS_DIR" fetch --depth 1 origin "$SWISS_COMMIT"
git -C "$SWISS_DIR" checkout --detach --force FETCH_HEAD >/dev/null
git -C "$SWISS_DIR" reset --hard "$SWISS_COMMIT" >/dev/null

ACTUAL_COMMIT="$(git -C "$SWISS_DIR" rev-parse HEAD)"
if [[ "$ACTUAL_COMMIT" != "$SWISS_COMMIT" ]]; then
  echo "Swiss commit drift: $ACTUAL_COMMIT != $SWISS_COMMIT" >&2
  exit 1
fi

make -C "$SWISS_DIR" "$SWISS_LIBRARY_NAME"
SWISS_LIBRARY="$SWISS_DIR/$SWISS_LIBRARY_NAME"
if [[ ! -f "$SWISS_LIBRARY" ]]; then
  echo "Swiss library was not built: $SWISS_LIBRARY" >&2
  exit 1
fi

rm -rf "$EPHE_DIR"
mkdir -p "$EPHE_DIR"

for file in "${REQUIRED_EPHE_FILES[@]}"; do
  source_file="$SWISS_DIR/ephe/$file"
  target_file="$EPHE_DIR/$file"
  if [[ ! -f "$source_file" ]]; then
    echo "missing pinned DE441 file: $source_file" >&2
    exit 1
  fi
  if ! head -c 512 "$source_file" | LC_ALL=C grep -a -q 'DE441'; then
    echo "not a DE441-generation Swiss file: $source_file" >&2
    exit 1
  fi
  cp "$source_file" "$target_file"
done

echo "DE441 staged: ${#REQUIRED_EPHE_FILES[@]} files"
echo "Swiss library: $SWISS_LIBRARY"
echo "DE441 directory: $EPHE_DIR"

echo "ORBOSPINE FORGE PREP / RELEASE TOOL"
pushd "$CORE_DIR" >/dev/null
swift build -c release --product OrboSpineForgeTool
BIN_DIR="$(swift build -c release --show-bin-path)"
popd >/dev/null

FORGE_TOOL="$BIN_DIR/OrboSpineForgeTool"
if [[ ! -x "$FORGE_TOOL" ]]; then
  echo "release forge tool not found: $FORGE_TOOL" >&2
  exit 1
fi

echo "OrboSpine forge tool: $FORGE_TOOL"
echo "output: $OUTPUT_DIR"

if [[ "$PREPARE_ONLY" -eq 1 ]]; then
  echo "status: apparatus prepared; celestial manufacture not started"
  exit 0
fi

mkdir -p "$OUTPUT_DIR"

echo "ORBOSPINE FORGE / START CELESTIAL MANUFACTURE"
"$FORGE_TOOL" \
  --library "$SWISS_LIBRARY" \
  --ephe-dir "$EPHE_DIR" \
  --output-dir "$OUTPUT_DIR"
