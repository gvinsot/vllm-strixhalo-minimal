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

Example stack service that runs on a specific node and uses the AMD runtime:

```yaml
my-service:
  image: rocm/pytorch:latest
  entrypoint: ["/bin/bash", "/rocm-test.sh"]
  environment:
    - AMD_VISIBLE_DEVICES=all
  configs:
    - source: rocm-test
      target: /rocm-test.sh
      mode: 0755
  networks:
    - proxy
  deploy:
    placement:
      constraints:
        - node.hostname == my-server
```

- **Placement**: `node.hostname == my-server` pins the service to the node named `my-server` (change to your GPU node hostname).
- **Config**: Define a config named `rocm-test` with the contents of `rocm-test.sh` so the container can run it.
- **Environment**: `AMD_VISIBLE_DEVICES=all` exposes all AMD GPUs to the container.

For vLLM, use the image from this repo (e.g. `vllm-strixhalo-minimal`) instead of `rocm/pytorch:latest`, set the appropriate entrypoint/command for the vLLM server, and keep `AMD_VISIBLE_DEVICES=all` and the same placement pattern.
