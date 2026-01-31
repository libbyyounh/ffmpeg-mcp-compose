FROM python:3.12-slim

# 1. 替换 APT 软件源（清华镜像）
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 uv（通过 pip 走清华源，避开 github 连接问题）
RUN pip install uv -i https://pypi.tuna.tsinghua.edu.cn/simple

# 3. 设置工作目录并克隆代码
WORKDIR /app
RUN git clone https://github.com/video-creator/ffmpeg-mcp.git .

# 4. 安装依赖（指定清华源）
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
RUN uv sync --frozen
# 确保安装了服务器运行必需的包
RUN uv add fastapi uvicorn

# 5. 暴力路径方案：环境变量与工作目录双管齐下
# 将 src 目录加入 Python 路径，这样无论在哪都能 import ffmpeg_mcp
ENV PYTHONPATH=/app/src
ENV FFMPEG_PATH=/usr/bin/ffmpeg
ENV FFPROBE_PATH=/usr/bin/ffprobe

# 切换到 main.py 所在的物理目录
WORKDIR /app/src/ffmpeg_mcp

# 暴露端口
EXPOSE 8032

# 6. 最终启动命令
# 使用 python -m uvicorn 保证环境隔离，直接加载当前目录下的 main:app
CMD ["uv", "run", "python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8032"]
