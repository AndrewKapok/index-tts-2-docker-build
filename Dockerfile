# 使用官方Python镜像作为基础（保留3.11版本，匹配依赖）
FROM python:3.11-slim-bookworm AS builder

# 关键：设置工作目录，后续所有操作集中在此，便于清理
WORKDIR /app

# 1. 安装系统依赖（合并指令，减少层）
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*  # 彻底清理APT缓存（释放500MB+）

# 2. 配置Git LFS并拉取代码（合并Git操作，避免中间层残留）
RUN git lfs install && \
    git clone https://github.com/index-tts/index-tts.git . && \
    git lfs pull && \
    # 清理Git冗余文件（.git目录可能占数百MB）
    rm -rf .git .gitattributes .gitignore

# 3. 安装依赖+下载模型（合并操作，清理中间缓存）
RUN pip install --no-cache-dir -U uv && \
    # 安装Python依赖，同时清理uv缓存
    uv sync --extra webui && uv cache clean && \
    # 安装HF工具+下载模型，下载后清理HF缓存
    uv tool install "huggingface-hub[cli,hf_xet]" && \
    uv run hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints && \
    uv tool uninstall huggingface-hub && \
    # 清理pip缓存（释放数百MB）
    rm -rf /root/.cache/pip /root/.cache/uv

# ------------------------------
# 阶段2：构建精简镜像（多阶段构建，剔除构建依赖）
# ------------------------------
FROM python:3.11-slim-bookworm

WORKDIR /app

# 仅复制构建阶段的必要文件（避免复制冗余依赖/缓存）
COPY --from=builder /app /app
COPY --from=builder /root/.local/share/uv /root/.local/share/uv

# 配置环境变量（指定模型路径，确保WebUI能找到）
ENV MODEL_PATH=/app/checkpoints \
    PYTHONUNBUFFERED=1 \
    PATH="/root/.local/share/uv/bin:$PATH"  # 添加uv到环境变量

# 暴露端口
EXPOSE 7860

# 启动命令（明确绑定0.0.0.0，允许外部访问）
CMD ["uv", "run", "webui.py", "--server-name", "0.0.0.0", "--server-port", "7860"]