FROM python:3.12-slim

# 1. 系统源优化
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 uv
RUN pip install uv -i https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /app

# 3. 克隆仓库
RUN git clone https://github.com/video-creator/ffmpeg-mcp.git .

# 4. 环境与依赖配置
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
# 使用 uv pip install 直接把当前目录 (.) 作为包安装到系统环境
# 这会自动处理 pyproject.toml 里的所有依赖
RUN uv pip install --system --no-cache .

# 5. 路径与环境变量
ENV PYTHONPATH=/app/src
ENV FFMPEG_PATH=/usr/bin/ffmpeg
ENV FFPROBE_PATH=/usr/bin/ffprobe

EXPOSE 8032

# 6. 启动指令
# 强制指定 --app-dir src 以确保 uvicorn 能够定位到包内容
CMD ["python", "-m", "uvicorn", "ffmpeg_mcp.main:app", "--app-dir", "src", "--host", "0.0.0.0", "--port", "8032"]
