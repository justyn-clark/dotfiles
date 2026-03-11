# ~/.dotfiles/zsh/media.zsh -- JCN media pipeline helpers
# --------------------------------------------------------

export JCN_ASSET_STUDIO_ROOT="$HOME/Agent/Projects/creative/jcn-asset-studio"
export JCN_GODOT_ASSET_LAB_ROOT="$HOME/Agent/Projects/gamedev/jcn-godot-asset-lab"
export JCN_GLTF_EXPORT_DIR="$JCN_ASSET_STUDIO_ROOT/exports/glb"
export JCN_GODOT_BLEND_EXPORT_MOUNT="$JCN_GODOT_ASSET_LAB_ROOT/assets/blender_exports"
export JCN_COMFYUI_ROOT="$HOME/Agent/Projects/creative/comfyui-local"
export JCN_COMFYUI_URL="http://127.0.0.1:8188"
export JCN_RECEIPTS_ROOT="$HOME/Agent/Ops/receipts"

alias assetstudio='cd "$JCN_ASSET_STUDIO_ROOT"'
alias godotlab='cd "$JCN_GODOT_ASSET_LAB_ROOT"'
alias glbexports='cd "$JCN_GLTF_EXPORT_DIR"'
alias comfyroot='cd "$JCN_COMFYUI_ROOT"'
alias comfyopen='open "$JCN_COMFYUI_URL"'
alias comfylogs='lsof -nP -iTCP:8188 -sTCP:LISTEN'

jcn_media_paths() {
  cat <<EOF
JCN_ASSET_STUDIO_ROOT=$JCN_ASSET_STUDIO_ROOT
JCN_GODOT_ASSET_LAB_ROOT=$JCN_GODOT_ASSET_LAB_ROOT
JCN_GLTF_EXPORT_DIR=$JCN_GLTF_EXPORT_DIR
JCN_GODOT_BLEND_EXPORT_MOUNT=$JCN_GODOT_BLEND_EXPORT_MOUNT
JCN_COMFYUI_ROOT=$JCN_COMFYUI_ROOT
JCN_COMFYUI_URL=$JCN_COMFYUI_URL
JCN_RECEIPTS_ROOT=$JCN_RECEIPTS_ROOT
EOF
}

jcn_blender_export_default_cube() {
  local out="${1:-$JCN_GLTF_EXPORT_DIR/pipeline-smoke-default-cube.glb}"
  mkdir -p "$(dirname "$out")"
  blender -b --python "$JCN_ASSET_STUDIO_ROOT/scripts/blender/export_scene_glb.py" -- --out "$out"
}

jcn_godot_import_lab() {
  godot --headless --path "$JCN_GODOT_ASSET_LAB_ROOT" --import --quit --verbose
}

jcn_blender_to_godot_smoke() {
  "$JCN_ASSET_STUDIO_ROOT/scripts/smoke_blender_to_godot.sh"
}

jcn_comfyui_start() {
  if lsof -nP -iTCP:8188 -sTCP:LISTEN >/dev/null 2>&1; then
    echo "ComfyUI already listening on $JCN_COMFYUI_URL"
    return 0
  fi

  local ts log_dir log_file
  ts="$(date +%Y%m%d-%H%M%S)"
  log_dir="$JCN_RECEIPTS_ROOT/comfyui"
  log_file="$log_dir/comfyui-$ts.log"
  mkdir -p "$log_dir"

  nohup "$JCN_COMFYUI_ROOT/run-comfyui.sh" >"$log_file" 2>&1 &
  echo "Started ComfyUI"
  echo "URL: $JCN_COMFYUI_URL"
  echo "Log: $log_file"
}

jcn_comfyui_open() {
  open "$JCN_COMFYUI_URL"
}

jcn_media_smoke() {
  set -euo pipefail

  local ts receipt_dir log_file meta_file export_path
  ts="$(date +%Y%m%d-%H%M%S)"
  receipt_dir="$JCN_RECEIPTS_ROOT/media-pipeline-smoke/$ts"
  log_file="$receipt_dir/run.log"
  meta_file="$receipt_dir/receipt.txt"
  export_path="$JCN_GLTF_EXPORT_DIR/pipeline-smoke-default-cube.glb"

  mkdir -p "$receipt_dir"

  {
    echo "JCN media pipeline smoke"
    echo "timestamp=$ts"
    echo "export_path=$export_path"
    echo "asset_studio=$JCN_ASSET_STUDIO_ROOT"
    echo "godot_lab=$JCN_GODOT_ASSET_LAB_ROOT"
    echo "comfyui_root=$JCN_COMFYUI_ROOT"
    echo
    echo "== blender export =="
    jcn_blender_export_default_cube "$export_path"
    echo
    echo "== godot import =="
    jcn_godot_import_lab
    echo
    echo "Smoke test complete: $export_path imported into $JCN_GODOT_ASSET_LAB_ROOT"
  } 2>&1 | tee "$log_file"

  {
    echo "receipt_dir=$receipt_dir"
    echo "log_file=$log_file"
    echo "export_path=$export_path"
    if [[ -f "$export_path" ]]; then
      shasum -a 256 "$export_path"
      stat -f 'size_bytes=%z mtime=%Sm' -t '%Y-%m-%dT%H:%M:%S%z' "$export_path"
    else
      echo "export_missing=true"
    fi
  } > "$meta_file"

  echo "Receipt: $receipt_dir"
}

jcn_media_pack() {
  "$JCN_ASSET_STUDIO_ROOT/scripts/run_media_pack.sh"
}
