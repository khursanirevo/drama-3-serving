#!/usr/bin/env bash
# Serve a drama-3 checkpoint (HF repo id or local path) via SGLang-Omni.
#
# Usage: ./serve.sh [model] [port]
#   model: HF repo id (auto-downloaded on first start) or a local checkpoint dir
#          default: Revolab/drama-3-malay-sft-half
#   port:  API port, default 8000
#
# Env:
#   SGLANG_OMNI_DIR  sglang-omni install root (default: ~/sglang-omni)
#   ENGINE_GPU       engine GPU id (default: 0)
#   VOCODER_GPU      vocoder GPU id (default: 1; set = ENGINE_GPU for one GPU)
#   CUDA_HOME        CUDA >= 12.9 toolkit (DeepGEMM JIT requirement)
#
# Private repos need HF auth first: hf login (token with read access to the repo).
set -euo pipefail

MODEL="${1:-Revolab/drama-3-malay-sft-half}"
PORT="${2:-8000}"
: "${SGLANG_OMNI_DIR:=$HOME/sglang-omni}"
ENGINE_GPU="${ENGINE_GPU:-0}"
VOCODER_GPU="${VOCODER_GPU:-1}"

export CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"
export PATH="$CUDA_HOME/bin:$PATH"

SGL_OMNI_BIN="$SGLANG_OMNI_DIR/.venv/bin/sgl-omni"
if [ ! -x "$SGL_OMNI_BIN" ]; then
  echo "ERROR: sgl-omni not found at $SGL_OMNI_BIN"
  echo ""
  echo "Install sglang-omni first:"
  echo "  git clone https://github.com/sgl-project/sglang-omni $SGLANG_OMNI_DIR"
  echo "  cd $SGLANG_OMNI_DIR"
  echo "  uv venv --python 3.12 .venv"
  echo "  uv pip install --prerelease=allow -e \".[fishaudio]\""
  exit 1
fi

TMPDIR="${TMPDIR:-/tmp/$USER-sglang}"
export TMPDIR
CONFIG_ARGS=""
if [ -n "${CONFIG_FILE:-}" ]; then CONFIG_ARGS=(--config "$CONFIG_FILE"); fi
exec "$SGL_OMNI_BIN" serve \
  "${CONFIG_ARGS[@]}" \
  --model-path "$MODEL" \
  --port "$PORT" \
  --tts_engine.gpu "$ENGINE_GPU" \
  --vocoder.gpu "$VOCODER_GPU"
