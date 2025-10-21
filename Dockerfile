# 使用官方 Python 运行时作为基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 初始化 Git LFS
RUN git lfs install

# 克隆 IndexTTS 仓库
RUN git clone https://github.com/index-tts/index-tts.git index-tts

WORKDIR /app/index-tts

# 安装 uv 包管理器
RUN pip install -U uv

# 同步 Python 依赖
RUN uv sync --extra webui

# 安装 huggingface-cli 并下载模型
RUN uv tool install "huggingface-hub[cli,hf_xet]" && \
    uv run hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints

# 暴露 Gradio 默认端口
EXPOSE 7860

# 设置环境变量
ENV PYTHONPATH=/app/index-tts
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860

# 启动 Web UI
CMD ["uv", "run", "python", "webui.py"]