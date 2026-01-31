FROM python:3.12-slim

# 1. 替换 APT 软件源
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update && apt-get install -y ffmpeg curl git && rm -rf /var/lib/apt/lists/*

# 2. 安装 uv (走清华源)
RUN pip install uv -i https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /app

# 3. 克隆仓库 (使用加速镜像)
RUN git clone https://github.com/video-creator/ffmpeg-mcp.git .

# 4. 安装依赖
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
# 显式安装 fastapi 和 uvicorn 确保它们在环境中可用
RUN uv sync --frozen && uv add fastapi uvicorn

# 5. 设置环境变量，确保 FFmpeg 路径正确
ENV FFMPEG_PATH=/usr/bin/ffmpeg
ENV FFPROBE_PATH=/usr/bin/ffprobe

EXPOSE 8032

# --- 关键修正：使用 python -m uvicorn 启动 ---
# 这样能绕过 "command not found" 的问题，并直接加载 src 下的代码
CMD ["uv", "run", "python", "-m", "uvicorn", "ffmpeg_mcp.main:app", "--host", "0.0.0.0", "--port", "8032"]
