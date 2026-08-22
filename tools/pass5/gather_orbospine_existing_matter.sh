#!/usr/bin/env bash
set -euo pipefail

# Gather already-built canonical Timespine matter beside the freshly forged C4
# celestial matter. This script copies existing canonical artifacts only.
# It does not forge, reinterpret, normalize, or modify their contents.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_ROOT="$REPO_ROOT/tools/pass5/orbospine-build"
CELESTIAL_DIR="$BUILD_ROOT/celestial"

if [[ ! -f "$CELESTIAL_DIR/orbospine-celestial-manifest.json" ]]; then
  echo "missing forged C4 celestial matter: $CELESTIAL_DIR/orbospine-celestial-manifest.json" >&2
  exit 1
fi

for tool in cp cmp shasum; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "missing required tool: $tool" >&2
    exit 1
  fi
done

ASPECT_ROOT="$BUILD_ROOT/aspects"
ECLIPSE_ROOT="$BUILD_ROOT/eclipses"
SHELL_ROOT="$BUILD_ROOT/shells"
PROVENANCE_ROOT="$BUILD_ROOT/provenance"

rm -rf "$ASPECT_ROOT" "$ECLIPSE_ROOT" "$SHELL_ROOT" "$PROVENANCE_ROOT"
mkdir -p \
  "$ASPECT_ROOT/z21" "$ASPECT_ROOT/z22" "$ASPECT_ROOT/z23" \
  "$ECLIPSE_ROOT/z21" "$ECLIPSE_ROOT/z22" "$ECLIPSE_ROOT/z23" \
  "$SHELL_ROOT" "$PROVENANCE_ROOT"

COPIES=(
  "tools/pass5/zeitgeist-relationship-data/z21/exact-major-mundane-transits.csv.gz|aspects/z21/exact-major-mundane-transits.csv.gz"
  "tools/pass5/zeitgeist-relationship-data/z21/exact-minor-mundane-transits.csv.gz|aspects/z21/exact-minor-mundane-transits.csv.gz"
  "tools/pass5/zeitgeist-relationship-data/z21/manifest.json|aspects/z21/manifest.json"

  "tools/pass5/p22-data/exact-major-mundane-transits.csv.gz|aspects/z22/exact-major-mundane-transits.csv.gz"
  "tools/pass5/p22-data/exact-minor-mundane-transits.csv.gz|aspects/z22/exact-minor-mundane-transits.csv.gz"

  "tools/pass5/zeitgeist-relationship-data/z23/exact-major-mundane-transits.csv.gz|aspects/z23/exact-major-mundane-transits.csv.gz"
  "tools/pass5/zeitgeist-relationship-data/z23/exact-minor-mundane-transits.csv.gz|aspects/z23/exact-minor-mundane-transits.csv.gz"
  "tools/pass5/zeitgeist-relationship-data/z23/manifest.json|aspects/z23/manifest.json"

  "tools/pass5/zeitgeist-eclipse-data/z21/eclipse-table.csv.gz|eclipses/z21/eclipse-table.csv.gz"
  "tools/pass5/zeitgeist-eclipse-data/z21/manifest.json|eclipses/z21/manifest.json"
  "tools/pass5/p22-data/eclipse-table.csv.gz|eclipses/z22/eclipse-table.csv.gz"
  "tools/pass5/zeitgeist-eclipse-data/z23/eclipse-table.csv.gz|eclipses/z23/eclipse-table.csv.gz"
  "tools/pass5/zeitgeist-eclipse-data/z23/manifest.json|eclipses/z23/manifest.json"

  "tools/pass5/temporal-shells/saturnian-frame-table.csv|shells/saturnian-frame-table.csv"
  "tools/pass5/temporal-shells/uranian-revolt-table.csv|shells/uranian-revolt-table.csv"
  "tools/pass5/temporal-shells/neptunian-wave-table.csv|shells/neptunian-wave-table.csv"
  "tools/pass5/zeitgeist-data/zeitgeist-z0-z30.csv|shells/zeitgeist-z0-z30.csv"

  "tools/pass5/p22-data/universal-events-manifest.json|provenance/z22-universal-events-manifest.json"
)

GATHERED=()

echo "ORBOSPINE / GATHER EXISTING MATTER"
echo "build: $BUILD_ROOT"
echo "celestial: already present"

for mapping in "${COPIES[@]}"; do
  IFS='|' read -r source_relative destination_relative <<< "$mapping"
  source="$REPO_ROOT/$source_relative"
  destination="$BUILD_ROOT/$destination_relative"

  if [[ ! -f "$source" ]]; then
    echo "missing canonical source artifact: $source_relative" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$destination")"
  cp -p "$source" "$destination"

  if ! cmp -s "$source" "$destination"; then
    echo "copy verification failed: $destination_relative" >&2
    exit 1
  fi

  GATHERED+=("$destination_relative")
  echo "gathered $destination_relative"
done

MANIFEST="$BUILD_ROOT/orbospine-existing-matter-manifest.json"
cat > "$MANIFEST" <<'JSON'
{
  "identity": "OrboSpine",
  "span": "Z21-Z23",
  "status": "existing canonical Timespine matter gathered; Terra Marrow pending",
  "celestial": {
    "directory": "celestial",
    "status": "C4 forged and audited",
    "supportRows": 1550229,
    "stationRows": 52679,
    "totalRecords": 1602908
  },
  "aspects": {
    "directory": "aspects",
    "status": "existing exact aspect tables gathered without alteration",
    "z21": {"majorRows": 309570, "minorRows": 463257, "totalRows": 772827},
    "z22": {"majorRows": 308474, "minorRows": 461819, "totalRows": 770293},
    "z23": {"majorRows": 309501, "minorRows": 463309, "totalRows": 772810},
    "totalRows": 2315930
  },
  "temporalShells": {
    "directory": "shells",
    "families": [
      "Frame / Saturn",
      "Revolt / Uranus",
      "Wave / Neptune",
      "Zeitgeist / Pluto"
    ],
    "address": "F.R.W.Z",
    "status": "canonical interval truth tables gathered without alteration"
  },
  "eclipses": {
    "directory": "eclipses",
    "status": "existing eclipse tables gathered without alteration",
    "z21Rows": 1221,
    "z22Rows": 1133,
    "z23Rows": 1185,
    "totalRows": 3539
  },
  "terraMarrow": {
    "directory": "terra",
    "status": "pending forge"
  },
  "excludedFromMatterGather": [
    "legacy P22 body tables superseded by C4 celestial forge",
    "legacy P22 station table superseded by C4 stations",
    "retrograde crossings/passages and planetary shadows because they are derived from stations plus ordered supports",
    "temporal-shell sign tables and summaries because they are derived views rather than shell interval truth",
    "Forge apparatus under .forge",
    "runtime indexes because Pass D has not begun",
    "Dioscuri and Hephaestus machinery because they manufacture or verify the Spine rather than constitute its astronomical matter"
  ]
}
JSON

HASH_FILE="$BUILD_ROOT/orbospine-existing-matter-sha256.txt"
: > "$HASH_FILE"
pushd "$BUILD_ROOT" >/dev/null
for relative in "${GATHERED[@]}"; do
  shasum -a 256 "$relative" >> "$HASH_FILE"
done
shasum -a 256 "orbospine-existing-matter-manifest.json" >> "$HASH_FILE"
popd >/dev/null

echo ""
echo "existing Timespine matter gathered"
echo "  celestial: $CELESTIAL_DIR"
echo "  aspects:   $ASPECT_ROOT"
echo "  shells:    $SHELL_ROOT"
echo "  eclipses:  $ECLIPSE_ROOT"
echo "  Terra:     pending at $BUILD_ROOT/terra"
echo "manifest: $MANIFEST"
echo "hashes:   $HASH_FILE"
