# 使用Python官方镜像作为基础
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    HF_ENDPOINT=https://xget.xi-xu.me/hf \
    UV_CACHE_DIR=/app/.uv-cache

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install

# 配置Git使用镜像加速
RUN git config --global url."https://xget.xi-xu.me/gh/".insteadOf "https://github.com/"

# 复制IndexTTS代码和模型
COPY index-tts-repo/ .

# 安装Python包管理工具uv
RUN pip install -U uv -i https://mirrors.aliyun.com/pypi/simple

# 安装Python依赖
RUN uv sync --extra webui --default-index "https://mirrors.aliyun.com/pypi/simple"

# 安装huggingface-cli工具
RUN uv tool install "huggingface-hub[cli,hf_xet]" -i "https://mirrors.aliyun.com/pypi/simple"

# 创建非root用户运行应用（安全最佳实践）
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# 暴露WebUI默认端口
EXPOSE 7860

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7860 || exit 1

# 启动命令
CMD ["uv", "run", "webui.py", "--listen", "--server-name", "0.0.0.0"]