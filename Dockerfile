# 使用官方Python镜像作为基础
FROM python:3.11-slim-bookworm

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y git git-lfs ffmpeg && apt-get clean && rm -rf /var/lib/apt/lists/*

# 配置Git LFS
RUN git lfs install

# 安装uv包管理器
RUN git clone https://github.com/index-tts/index-tts.git

WORKDIR /app/index-tts

RUN git lfs pull

RUN pip install -U uv && uv sync --extra webui

# 创建模型存储目录
RUN mkdir -p /app/checkpoints

# 复制本地checkpoint模型文件到容器（从GitHub Actions中下载的模型）
COPY index-tts-repo/checkpoints /app/checkpoints

# 暴露WebUI端口（默认7860）
EXPOSE 7860

# 设置环境变量，指定模型路径
ENV MODEL_PATH=/app/checkpoints
ENV PYTHONUNBUFFERED=1

# 启动命令（根据实际启动方式调整）
CMD ["uv", "run", "webui.py"]
