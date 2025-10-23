FROM python:3.11-slim-bookworm AS builder

WORKDIR /app

# 在依赖安装前添加，查看初始空间
RUN echo "=== 初始空间分配 ===" && df -h /app && \
    echo "=== 存储驱动配置 ===" && cat /etc/buildkitd.toml 2>/dev/null
    
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN git lfs install && \
    git clone --depth 1 https://github.com/index-tts/index-tts.git . && \
    git lfs pull && \
    rm -rf .git .gitattributes .gitignore

RUN apt-get purge -y git git-lfs && apt-get autoremove -y && apt-get clean

RUN pip install --no-cache-dir -U uv && \
    uv sync --extra webui && \
    uv cache clean && \
    rm -rf /root/.cache/pip

# RUN uv tool install "huggingface-hub[cli,hf_xet]" && \
#    uv run hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints && \
#    uv tool uninstall huggingface-hub && \
#    rm -rf /root/.cache/uv

CMD ["uv","run",webui.py]