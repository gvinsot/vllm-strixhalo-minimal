# Custom vLLM Docker Image

Minimal, stable Docker image to run **vLLM** on **AMD Strix Halo** (ROCm, Navi/gfx1150). Text-only LLMs; no vision or multimodal.

**Prerequisites:** Prepare the machine (Docker + AMD GPU, or Swarm on AMD nodes) → [SETUP.md](SETUP.md).

---

## Current status

After a lot of tuning (multi-stage build, stripping, arch-specific kernels, removing dev/docs/tooling), the image is down to **~37.9 GB**. That’s still too large for many use cases. This repo tracks ongoing research into a smaller footprint.

**Scope:** This image is **exclusively for text LLMs**. It was created because other vLLM/ROCm images were not stable in my environment; this one is trimmed for reliability and minimal size. See [README.md](README.md#references) for referenced alternatives (e.g. **kyuz0/vllm-therock-gfx1151**, updated every 3 hours — not stable enough for production).

---

## What the image does

- **Base**: Built from the official `rocm/vllm-dev` image (ROCM 7.2, Ubuntu 24.04, PyTorch 2.9, vLLM 0.14.0).
- **Multi-stage build**: Builder stage trims everything that isn’t needed at runtime; final stage is a slim `ubuntu:24.04` with only required runtime bits.
- **ROCm slim-down**: Static libs (`.a`), LLVM, MIGraphX, headers, docs, profilers/tracers removed; only runtime `.so` and minimal ROCm bin tools kept.
- **Strix Halo–only kernels**: Keeps only **gfx1150** kernels in `rocblas` and `hipblaslt`; other GPU families are dropped to save space.
- **Debug stripping**: Debug symbols stripped from ROCm and Python extension `.so` files.
- **Python/vLLM cleanup**: Pip/wheel/cmake, `__pycache__`, tests, torch test/include, and NVIDIA-related packages removed from the venv.

Default entrypoint: vLLM OpenAI-compatible API server.

---

## Build

```bash
docker build -t vllm-minimal .
```

(Use `vllm-strixhalo-minimal` or any tag you prefer.)

---

## Run (standalone)

```bash
docker run --device=/dev/kfd --device=/dev/dri -p 8000:8000 \
  -e HUGGING_FACE_HUB_TOKEN="hf_xxx" \
  vllm-minimal --model your/model-name
```

Requires AMD GPU drivers and ROCm support on the host (Strix Halo / Navi).

---

## Test (example with gpt-oss-20b)

Replace `hf_xxx` with your Hugging Face token:

```bash
docker run -it --rm \
  -e AMD_VISIBLE_DEVICES=all \
  --shm-size 16g \
  -e HUGGING_FACE_HUB_TOKEN="hf_xxx" \
  -p 8000:8000 \
  vllm-minimal \
  --model openai/gpt-oss-20b \
  --gpu-memory-utilization 0.40 \
  --enforce-eager \
  --host 0.0.0.0
```

Then call the API on `http://localhost:8000` (e.g. `/v1/completions` or `/v1/chat/completions`).

---

## Goals

- **Current**: Document and maintain the smallest known working vLLM-on-Strix-Halo image (~37.9 GB).
- **Ongoing**: Experiment with further reductions (slimmer base, fewer Python deps, more aggressive pruning) and record results here.

If you’re also chasing a smaller vLLM + Strix Halo image, feel free to open issues or PRs with ideas and Dockerfile variants.
