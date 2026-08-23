#!/usr/bin/env bash
# Download the published native GGUF bundle into Kimodo's standard paths.
set -euo pipefail
export HF_HUB_DISABLE_PROGRESS_BARS=1

ORG="${GGUF_ORG:-LocalAI-io}"
MOTION_REPO_DEFAULT="$ORG/Kimodo-SMPLX-RP-v1-GGML"
TEXT_REPO_DEFAULT="$ORG/Llama-3-Kimodo-GGML"

usage() {
    printf '%s\n' "usage: $0 --output DIR [--motion-repo HF_REPO] [--text-repo HF_REPO] [--revision REVISION] [--motion-only]" >&2
    exit 2
}

output='' motion_repo="$MOTION_REPO_DEFAULT" text_repo="$TEXT_REPO_DEFAULT" revision='main' motion_only=0
while [ "$#" -gt 0 ]; do
    case "$1" in
        --output) [ "$#" -ge 2 ] || usage; output=$2; shift 2 ;;
        --motion-repo) [ "$#" -ge 2 ] || usage; motion_repo=$2; shift 2 ;;
        --text-repo) [ "$#" -ge 2 ] || usage; text_repo=$2; shift 2 ;;
        --revision) [ "$#" -ge 2 ] || usage; revision=$2; shift 2 ;;
        --motion-only) motion_only=1; shift ;;
        *) usage ;;
    esac
done
[ -n "$output" ] || usage
command -v hf >/dev/null || { echo "hf not found; enter the Nix shell first" >&2; exit 1; }

mkdir -p "$output"

download_and_verify() { # repo include-pattern...
    local repo=$1; shift
    local manifest_dir="$output/.kimodo-manifests/${repo//\//__}"
    mkdir -p "$manifest_dir"
    echo "Downloading $repo at $revision into $output"
    local args=(download "$repo" --revision "$revision" --local-dir "$output")
    local pattern
    for pattern in "$@"; do args+=(--include "$pattern"); done
    hf "${args[@]}" >/dev/null
    hf download "$repo" --revision "$revision" --local-dir "$manifest_dir" --include MANIFEST.json >/dev/null
    python - "$manifest_dir/MANIFEST.json" "$output" "$@" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
output = Path(sys.argv[2])
root = output.resolve()
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
if manifest.get("format") != "kimodo-gguf-manifest-v1":
    raise SystemExit("unsupported or malformed GGUF manifest")
requested = sys.argv[3:]
for entry in manifest.get("files", []):
    relative = Path(entry.get("path", ""))
    if relative.is_absolute() or ".." in relative.parts or relative.suffix != ".gguf":
        raise SystemExit(f"unsafe manifest path: {relative}")
    if not any(relative.match(pattern) for pattern in requested):
        continue
    path = root / relative
    if not path.is_file() or path.stat().st_size != entry.get("bytes"):
        raise SystemExit(f"missing or wrong-sized file: {relative}")
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    if h.hexdigest() != entry.get("sha256"):
        raise SystemExit(f"checksum mismatch: {relative}")
print("verified native Kimodo GGUF bundle")
PY
}

download_and_verify "$motion_repo" "models/kimodo-smplx-rp-v1-f32.gguf"
if [ "$motion_only" -eq 0 ]; then
    download_and_verify "$text_repo" "generated/llm2vec-text-bundle/*"
fi
