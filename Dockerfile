FROM python:3.12-slim

# 1. 软件源优化
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update && apt-get install -y ffmpeg curl git && rm -rf /var/lib/apt/lists/*

# 2. 安装 uv
RUN pip install uv -i https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /app

# 3. 克隆代码
RUN git clone https://github.com/video-creator/ffmpeg-mcp.git .

# 4. 依赖安装 (全局模式)
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
RUN uv pip install --system --no-cache .
# 显式补强 FastAPI 相关依赖
RUN uv pip install --system fastapi uvicorn

# 5. 设置环境变量
ENV FFMPEG_PATH=/usr/bin/ffmpeg
ENV FFPROBE_PATH=/usr/bin/ffprobe
# 将 src 加入路径，确保从任何地方都能 import ffmpeg_mcp
ENV PYTHONPATH=/app/src

# 6. 启动指令：直接进入目录执行，绕过包名查找
# 在 src/ffmpeg_mcp 目录下，main.py 就是顶层文件
WORKDIR /app/src/ffmpeg_mcp
EXPOSE 8032

# 直接启动 uvicorn，将当前目录作为应用根目录
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8032"]
