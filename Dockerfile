# 使用多阶段构建来减小最终镜像大小
FROM python:3.10-slim as builder

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 初始化 Git LFS
RUN git lfs install

WORKDIR /app

# 复制 IndexTTS 仓库内容
COPY index-tts-repo/ /app/index-tts/

WORKDIR /app/index-tts

# 安装 uv 包管理器
RUN pip install -U uv

# 同步 Python 依赖（不安装开发依赖）
RUN uv sync --extra webui

# 清理缓存
RUN uv cache clean

# 最终阶段
FROM python:3.10-slim

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /app

# 从构建阶段复制必要文件
COPY --from=builder /app/index-tts /app/index-tts

# 复制模型文件（单独复制以避免层过大）
COPY index-tts-repo/checkpoints/ /app/index-tts/checkpoints/

WORKDIR /app/index-tts

# 暴露 Gradio 默认端口
EXPOSE 7860

# 设置环境变量
ENV PYTHONPATH=/app/index-tts
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860
ENV UV_CACHE_DIR=/tmp/uv-cache

# 创建缓存目录
RUN mkdir -p /tmp/uv-cache

# 启动 Web UI
CMD ["uv", "run","webui.py"]