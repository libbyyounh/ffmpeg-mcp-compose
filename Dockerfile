# 使用 Debian 12 (Bookworm) 基础镜像
FROM python:3.12-slim

# 1. 替换 APT 软件源为清华大学镜像 (Debian 12 使用的是新版 sources.list.d 格式)
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources

# 2. 安装基础依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 3. 安装 uv 并配置镜像源
# 使用环境变量让 uv 永久使用清华源
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
# 如果 curl githubusercontent 太慢，这里可以尝试国内 Gitee 或镜像
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:${PATH}"

# 设置工作目录
WORKDIR /app

# 4. 克隆仓库 (使用 ghproxy.net 加速 GitHub 访问)
RUN git clone https://ghproxy.net/https://github.com/video-creator/ffmpeg-mcp.git .

# 5. 使用 uv 安装依赖 (uv 会自动识别上面的 UV_INDEX_URL)
# 禁用 uv 自动更新，防止连接官方服务器
RUN uv sync --frozen

# 暴露端口
EXPOSE 8032

# 启动命令
CMD ["uv", "run", "ffmpeg-mcp", "--transport", "sse", "--host", "0.0.0.0", "--port", "8032"]
