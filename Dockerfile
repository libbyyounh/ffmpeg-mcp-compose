FROM python:3.12-slim

# 1. 替换 APT 软件源为清华镜像
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources

# 2. 安装基础依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 3. --- 优化点：通过 Pip 安装 uv ---
# 这样会直接走清华源的 PyPI，速度非常快，且不需要通过 curl 访问国外服务器
RUN pip install uv -i https://pypi.tuna.tsinghua.edu.cn/simple

# 设置工作目录
WORKDIR /app

# 4. 克隆仓库 (使用 ghproxy 加速)
RUN git clone https://github.com/video-creator/ffmpeg-mcp.git .

# 5. 安装依赖 (配置 uv 内部也使用清华源)
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
RUN uv sync --frozen

# 端口和启动配置保持不变
EXPOSE 8032
CMD ["uv", "run", "ffmpeg-mcp", "--transport", "sse", "--host", "0.0.0.0", "--port", "8032"]
