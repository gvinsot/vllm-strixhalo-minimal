# Efficient LLM API on AMD Strix Halo

This repo exposes my **research to run LLMs in the most efficient way** for an **API on AMD Strix Halo**: hardware choice, orchestration, and the serving stack. Everything is split into focused docs—use the index below.

---

## Objective

Run a **production-ready LLM API** on **Strix Halo** with the best trade-off between **cost**, **simplicity**, and **throughput**: why Strix Halo, how to orchestrate multiple nodes with Docker Swarm, and why vLLM in a custom Docker image (instead of Ollama/llama.cpp) for now.

---

## Documentation

| Topic | File | Summary |
|-------|------|---------|
| **Halo Strix advantage** | [HALO-STRIX.md](HALO-STRIX.md) | Pros and cons of Strix Halo for LLM API (cost, power, integration). |
| **Swarm simplicity** | [SETUP.md](SETUP.md) | How to set up a Swarm that runs GPU containers on AMD. |
| **Architecture** | [ARCHITECTURE.md](ARCHITECTURE.md) | Schema: multiple Strix Halo nodes in Swarm. |
| **Why vLLM** | [WHY-VLLM.md](WHY-VLLM.md) | Ollama/llama.cpp (Vulkan) vs vLLM; why a custom vLLM image for now. |

---

## Quick start

**Prerequisites:** Prepare the machine (Docker + AMD GPU, or Swarm on AMD nodes) 

→ [SETUP.md](SETUP.md).

**Run vLLM image using docker:**

```bash
docker run -it --rm -e AMD_VISIBLE_DEVICES=all \
  -e HUGGING_FACE_HUB_TOKEN="hf_xxx" -p 8000:8000 \
  gvinsot/vllm-strixhalo-minimal:latest --model openai/gpt-oss-20b --gpu-memory-utilization 0.40
```


**Run vLLM in swarm:**

```bash
  vllm-service:
    image: gvinsot/vllm-strixhalo-minimal:latest
    command: ["--model", "openai/gpt-oss-20b", "--gpu-memory-utilization", "0.40"]
    networks:
      - proxy
    environment:
      - AMD_VISIBLE_DEVICES=all
      - HUGGING_FACE_HUB_TOKEN=${HF_TOKEN:-}
```

---

## References

- **[kyuz0/vllm-therock-gfx1151](https://hub.docker.com/r/kyuz0/vllm-therock-gfx1151)** — vLLM image for The Rock / gfx1151; rebuilt every 3 hours, I used it selecting a well working version for me.
