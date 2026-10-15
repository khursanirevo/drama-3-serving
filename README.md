# drama-3-serving

Serving kit for [Revolab/drama-3-malay-sft-half](https://huggingface.co/Revolab/drama-3-malay-sft-half) — a LoRA finetune of [fishaudio/drama-3](https://huggingface.co/fishaudio/fish-speech) for Malay text-to-speech, built on [SGLang-Omni](https://github.com/sgl-project/sglang-omni).

## Serve

```bash
export CUDA_HOME=/usr/local/cuda-13.0   # DeepGEMM JIT needs nvcc >= 12.9
./serve.sh                # pulls the model from HF on first start (needs hf login with org access)
# or an explicit path:
./serve.sh /path/to/local/checkpoint
```

Engine on GPU 0, vocoder on GPU 1. Single GPU: drop the two --*.gpu flags in serve.sh.

## Web UI

```bash
python3 -m http.server 8080 --directory ui
```

Open http://<box-ip>:8080. Reference voices, transcripts, tag insertion, take history, and the prompt-craft guardrails are built in. The API is CORS-open, so the UI can also be opened as a plain file with the server field pointing at the box.

## API

Full curl examples in [api_examples.md](api_examples.md). Fast form:

```bash
curl -X POST http://localhost:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{"input": "Selamat pagi semua."}' --output out.wav
```

Voice cloning always sends the reference transcript; without it similarity drops by about 0.2 cosine.

## Prompt craft

- Never open a line with a tag; leading tags cause silent takes
- Keep tag density at three or fewer per line
- Tags: [sighs] [laughs] [pause] [gasps] [hesitates] [coughs] [clears throat], <slow> <emphasis> <whisper>
- Style prefixes like [with bright eager excitement] set the whole line
