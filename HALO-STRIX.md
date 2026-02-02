# Halo Strix: Pros and Cons for LLM API

Why target **AMD Strix Halo** for running an LLM API, and what to expect in terms of cost and trade-offs.

---

## What is Strix Halo?

Strix Halo is AMD’s **APU** (CPU + integrated GPU) with a large **RDNA 3.5** iGPU (Navi, gfx1150). It’s a single chip with strong GPU compute and unified memory, aimed at AI and gaming workloads.

---

## Pros (advantages)

- **Cost**  
  One chip replaces separate CPU + discrete GPU. Lower total hardware cost and power supply complexity. Good for **cost per inference** when you don’t need top-tier discrete GPUs.

- **Unified memory**  
  CPU and GPU share memory. No PCIe copy for model weights; can reduce latency and simplify deployment compared to CPU + dGPU setups.

- **Power efficiency**  
  APU typically uses less power than a high-end CPU + dGPU combo, which helps for **power cost** and cooling.

- **Compact**  
  Fits in smaller or standard PC form factors. Easier to scale out with **multiple Strix Halo machines** (e.g. one node per box in a Swarm).

- **ROCm support**  
  Supported under ROCm (e.g. gfx1150), so you can run **vLLM** and other ROCm-based stacks for LLM serving.

---

## Cons (limitations)

- **Single-node performance**  
  iGPU is not as powerful as high-end discrete GPUs (e.g. high-end NVIDIA). For very large models or very high QPS, a big dGPU or multiple nodes may be needed.

- **Memory ceiling**  
  System RAM is the only VRAM. Capacity is limited by how much RAM you put in the machine (e.g. 32–64 GB). No 80 GB “VRAM” option like on some dGPUs.

- **ROCm maturity on APU**  
  ROCm is more battle-tested on discrete AMD GPUs. On Strix Halo you may hit edge cases; this repo’s image and settings are tuned for **stability** on this target.

- **Ecosystem**  
  Fewer ready-made “Strix Halo + LLM” guides and images than for NVIDIA. This repo is part of that: a **minimal, stable** image and a clear path (Swarm + vLLM).

---

## Summary

Strix Halo is a **cost-effective** and **simple** base for an LLM API when you prioritize efficiency and scaling by **adding more nodes** rather than buying the biggest GPUs. The trade-off is per-node throughput and memory vs high-end discrete GPUs; for many API workloads, **multiple Strix Halo nodes** behind a load balancer are a good fit.

For orchestration of multiple Strix Halo nodes, see [SETUP.md](SETUP.md) and [ARCHITECTURE.md](ARCHITECTURE.md).
