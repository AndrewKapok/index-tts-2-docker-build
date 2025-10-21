# 使用官方 Python 运行时作为基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 初始化 Git LFS
RUN git lfs install

# 复制 IndexTTS 仓库内容
COPY index-tts-repo/ /app/index-tts/

WORKDIR /app/index-tts

# 安装 uv 包管理器
RUN pip install -U uv

# 同步 Python 依赖
RUN uv sync --extra webui

# 复制预下载的模型文件
COPY index-tts-repo/checkpoints/ /app/index-tts/checkpoints/

# 创建模型软链接（如果需要）
RUN ln -sf /app/index-tts/checkpoints /app/checkpoints

# 暴露 Gradio 默认端口
EXPOSE 7860

# 设置环境变量
ENV PYTHONPATH=/app/index-tts
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860

# 启动 Web UI
CMD ["uv", "run", "python", "webui.py"]