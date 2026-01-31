FROM python:3.12-slim

# 1. 软件源优化
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update && apt-get install -y ffmpeg curl git && rm -rf /var/lib/apt/lists/*

# 2. 安装 uv
RUN pip install uv -i https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /app

# 3. 克隆代码
RUN git clone https://github.com/video-creator/ffmpeg-mcp.git .

# 4. 依赖安装
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
RUN uv sync --frozen
RUN uv add fastapi uvicorn

# 5. 关键：设置 PYTHONPATH 指向 src 
# 这样 ffmpeg_mcp 文件夹就被视为一个合法的 Python 包
ENV PYTHONPATH=/app/src
ENV FFMPEG_PATH=/usr/bin/ffmpeg
ENV FFPROBE_PATH=/usr/bin/ffprobe

EXPOSE 8032

# 6. 启动命令：从根目录启动，并指定包路径
# 注意这里是 ffmpeg_mcp.main:app
CMD ["uv", "run", "python", "-m", "uvicorn", "ffmpeg_mcp.main:app", "--host", "0.0.0.0", "--port", "8032"]
