# Setup: Docker Swarm with AMD GPUs

How to set up a **Docker Swarm** that runs containers on **AMD GPUs** (e.g. multiple Strix Halo nodes). For a high-level view of the architecture (multiple Strix Halo nodes behind a load balancer), see **[ARCHITECTURE.md](ARCHITECTURE.md)**.

After many tries, the path below was the easiest way to get Swarm + AMD GPUs working. The official approach ([AMD Container Toolkit – Docker Swarm](https://instinct.docs.amd.com/projects/container-toolkit/en/latest/container-runtime/docker-swarm.html)) was not reliable in my environment and cost a lot of time; this flow worked.

---

## 1. Install AMD Container Toolkit

On each node that will run GPU workloads, install the AMD container toolkit (add AMD’s repo and install the package; see [AMD Container Toolkit docs](https://instinct.docs.amd.com/projects/container-toolkit/) for your distro if needed):

```bash
# Example for Ubuntu/Debian (adjust for your distro and AMD's current instructions)
# Add AMD repo, then:
sudo apt-get update
sudo apt-get install -y amd-container-toolkit
```

---

## 2. Configure nodes that have an AMD GPU

On every node with an AMD GPU, set the default Docker runtime to `amd` and register the AMD runtime.

Edit the Docker daemon config:

```bash
sudo nano /etc/docker/daemon.json
```

Use this content (merge with any existing `daemon.json` keys you already have):

```json
{
    "default-runtime": "amd",
    "runtimes": {
        "amd": {
            "args": [],
            "path": "amd-container-runtime"
        }
    }
}
```

Then restart the Docker daemon:

```bash
sudo systemctl restart docker
```

---

## 3. Run a service in Swarm

Example stack that runs **Ollama** on a GPU node. No extra scripts or configs—the image runs as-is. Save as `stack.yml` and deploy with `docker stack deploy -c stack.yml my-stack`.

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    environment:
      - AMD_VISIBLE_DEVICES=all
      - OLLAMA_HOST=0.0.0.0
    volumes:
      - ollama:/root/.ollama
    ports:
      - "11434:11434"
    networks:
      - proxy
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.hostname == my-server

networks:
  proxy:
    external: true

volumes:
  ollama:
```

- **Placement**: `node.hostname == my-server` pins the service to your GPU node (change to that node’s hostname).
- **Environment**: `AMD_VISIBLE_DEVICES=all` exposes AMD GPUs; `OLLAMA_HOST=0.0.0.0` makes the API reachable on the network.
- **Volume**: `ollama` persists models under `/root/.ollama` so they survive restarts.
- **Network**: Create the `proxy` overlay network beforehand with `docker network create -d overlay proxy` (or use an existing one).

To use **vLLM** instead of Ollama, use this repo’s image with the same placement and `AMD_VISIBLE_DEVICES=all`, and set `VLLM_MODEL` / `VLLM_GPU_MEMORY_UTILIZATION` and `HUGGING_FACE_HUB_TOKEN` via `environment`. The image defaults work; add `shm_size: '16g'` at service level if vLLM needs more shared memory.
