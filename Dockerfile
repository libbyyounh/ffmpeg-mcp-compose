FROM python:3.12-slim

# ... 前面安装 FFmpeg、Git 和 uv 的步骤保持不变 ...
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update && apt-get install -y ffmpeg curl git && rm -rf /var/lib/apt/lists/*
RUN pip install uv -i https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /app
RUN git clone https://ghproxy.net/https://github.com/video-creator/ffmpeg-mcp.git .

# 安装依赖
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
RUN uv sync --frozen

# --- 修正后的启动部分 ---
# 根据 README，该项目是一个 FastAPI 应用
# 我们需要运行 src/ffmpeg_mcp/main.py 
EXPOSE 8032

# 使用 uv run 来确保在虚拟环境中执行 fastapi
# 注意：路径必须指向 main.py 所在的实际位置
CMD ["uv", "run", "fastapi", "run", "src/ffmpeg_mcp/main.py", "--port", "8032", "--host", "0.0.0.0"]
