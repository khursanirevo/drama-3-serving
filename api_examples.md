# Serving + API examples: Revolab/drama-3-malay-sft-half (e2)

## 1. Serve (target machine with CUDA 12.9+ driver, sglang-omni installed)

```bash
export CUDA_HOME=/usr/local/cuda-13.0   # DeepGEMM JIT needs nvcc >= 12.9
sgl-omni serve \
  --model-path Revolab/drama-3-malay-sft-half \
  --port 8000 \
  --tts_engine.gpu 0 \
  --vocoder.gpu 1
```

First start downloads ~39 GB from this repo. Two-GPU layout: engine on 0, vocoder on 1. Single GPU: drop the two --*.gpu flags.

## 2. Plain text-to-speech

```bash
curl -X POST http://localhost:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{"input": "Selamat pagi semua. Hari ini kita ada berita besar."}' \
  --output out.wav
```

## 3. Voice cloning (reference audio + its transcript)

The transcript is REQUIRED for best results with this checkpoint; without it voice similarity drops by about 0.2 cosine.

```bash
curl -X POST http://localhost:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Ini ujian klon suara. Kalau awak boleh dengar ini dengan jelas, klon kita berjaya.",
    "references": [{
      "audio_path": "https://example.com/speaker_clip.wav",
      "text": "what the reference clip actually says, written out"
    }]
  }' \
  --output clone.wav
```

Local reference files also work: "audio_path": "/path/to/clip.wav".

## 4. Inline control tags

Tags are written into the input text at the position they should occur.

```bash
curl -X POST http://localhost:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "input": "[sighs] Penat betul hari ni. <whisper>Eh, sekejap. Adik baru tidur.</whisper> [pause] Kau dah makan belum? [laughs] Kalau kau yang belanja, lagi bagus."
  }' \
  --output styled.wav
```

Supported: point tags [sighs] [laughs] [pause] [gasps] [hesitates] [coughs] [clears throat], scoped tags <slow>..</slow> <emphasis>..</emphasis> <whisper>..</whisper>, style prefixes like [with bright eager excitement] at line start, language hints [language: ms].

Prompt craft: never open a line with a tag, keep tag density low, plain opening then tags mid-line.

## 5. Streaming

```bash
curl -N -X POST http://localhost:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{"input": "Berita hari ini dibawakan oleh pasukan penyiar kami.", "stream": true, "response_format": "pcm"}' \
  --output stream.pcm
```

Limits: reference audio max 60 s, prompt max 8192 rows, reference max 6 GiB preprocessing reserve by default.
