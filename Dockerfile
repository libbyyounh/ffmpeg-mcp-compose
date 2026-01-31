FROM python:3.12-slim

# 1. 系统源优化（清华镜像）
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 uv (走清华源 PyPI)
RUN pip install uv -i https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /app

# 3. 克隆仓库 (直接拉取原地址)
RUN git clone https://github.com/video-creator/ffmpeg-mcp.git .

# 4. 环境与依赖配置
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
# 使用 --system 标志将依赖直接安装在容器全局环境，解决路径识别问题
RUN uv sync --frozen --system
RUN uv pip install fastapi uvicorn --system

# 5. 路径与环境变量
ENV PYTHONPATH=/app/src
ENV FFMPEG_PATH=/usr/bin/ffmpeg
ENV FFPROBE_PATH=/usr/bin/ffprobe

EXPOSE 8032

# 6. 启动指令：指定 app-dir 为 src
CMD ["python", "-m", "uvicorn", "ffmpeg_mcp.main:app", "--app-dir", "src", "--host", "0.0.0.0", "--port", "8032"]
