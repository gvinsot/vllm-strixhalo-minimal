# Why vLLM (and a Custom Image) for the API

Ollama and llama.cpp are very compatible on Strix Halo (e.g. via **Vulkan**), but they don’t handle **parallelism** well for an API. So this stack uses **vLLM** in a **custom Docker image** for now.

---

## Ollama and llama.cpp: pros and cons

**Pros:**

- **Vulkan** support works well on AMD/Strix Halo; no ROCm required for basic inference.
- **Easy** to install and run locally (Ollama in particular).
- **Wide model support** (GGUF, etc.) and active ecosystem.

**Cons for an API:**

- **Limited request parallelism**: they are geared to one (or a few) requests at a time. For an **API** with multiple concurrent clients, you don’t get the same throughput as a server built for batching.
- **No continuous batching**: no equivalent to vLLM’s continuous batching, which is a major advantage for latency and GPU utilization under load.
- **API story**: Ollama has an API, but it’s not optimized for high concurrency; llama.cpp is a library, so you’d still need to build or glue an API layer and parallelism yourself.

So for a **dedicated LLM API** with concurrent requests and good GPU utilization, they are not the best fit.

---

## Why vLLM for this repo

- **Designed for serving**: batching, continuous batching, and OpenAI-compatible API out of the box.
- **Throughput**: much better **parallelism** and GPU utilization under load than Ollama/llama.cpp for API workloads.
- **ROCm support**: runs on Strix Halo (gfx1150) via ROCm, which is the path chosen here for stability and performance.

Trade-off: ROCm + vLLM is heavier and less “drop-in” than Vulkan + Ollama/llama.cpp, so we use a **custom Docker image** to keep it minimal and stable.

---

## Why a custom Docker image

- **Stability**: Off-the-shelf vLLM/ROCm images were not stable in my environment; this image is trimmed and tested for **Strix Halo**.
- **Size**: Multi-stage build, Strix Halo–only kernels (gfx1150), and stripping keep the image as small as possible (~37.9 GB today; see [IMAGE.md](IMAGE.md)).
- **Scope**: **Text-only LLMs**; no vision/multimodal. That keeps the image and runtime simpler.

So: **Ollama and llama.cpp are great for Vulkan and local use, but they don’t handle API parallelism well. For an efficient LLM API on Strix Halo we use vLLM in a custom Docker image.**

Details of the image and how to build/run it → [IMAGE.md](IMAGE.md).
