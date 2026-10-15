#!/bin/bash
# Serve fishaudio/drama-3 (or a finetune) via SGLang-Omni.
# Usage: serve.sh [model_dir]   (default: the base checkpoint)
# CUDA_HOME must be >= 12.9 for DeepGEMM's JIT compiler (box default is 12.8).
cd /mnt/data/work/fishdrama/sglang-omni
export CUDA_VISIBLE_DEVICES=0,2
export CUDA_HOME=/usr/local/cuda-13.0
export PATH=$CUDA_HOME/bin:$PATH
MODEL_DIR="${1:-/mnt/data/work/fishdrama/models/drama-3}"
exec .venv/bin/sgl-omni serve \
  --model-path "$MODEL_DIR" \
  --port 8000 \
  --tts_engine.gpu 0 \
  --vocoder.gpu 1
