# vLLM OpenAI API server for AMD GFX1151 (Strix/Halo)
#   build: docker build -t your-registry/vllm-therock:latest .
#   run:   docker run -it --rm --shm-size 16g -e HUGGING_FACE_HUB_TOKEN=hf_xxx -e VLLM_MODEL=... -e VLLM_GPU_MEMORY_UTILIZATION=0.5 -p 8000:8000 your-registry/vllm-therock:latest
FROM kyuz0/vllm-therock-gfx1151:20260202-084655

ENV AMD_VISIBLE_DEVICES=all
ENV VLLM_MODEL=Qwen/Qwen3-0.6B

EXPOSE 8000

ENTRYPOINT ["/bin/sh", "-c", "exec python3 -m vllm.entrypoints.openai.api_server --enforce-eager --host 0.0.0.0 --model $VLLM_MODEL \"$@\"", "--"]
CMD []
