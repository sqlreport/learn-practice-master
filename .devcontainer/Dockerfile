# Use the official Microsoft devcontainer base image
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    wget \
    git \
    build-essential \
    python3-dev \
    python3-pip \
    python3-venv \
    postgresql-client \
    libpq-dev \
    pkg-config \
    nginx \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Create Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip
RUN pip install --upgrade pip

# Set working directory
WORKDIR /workspace

# Create directories for logs and data
RUN mkdir -p /var/log/myapp /var/lib/myapp

# Set proper permissions
RUN chown -R vscode:vscode /workspace /var/log/myapp /var/lib/myapp /opt/venv

# Switch to vscode user
USER vscode

# Set environment variables
ENV FLASK_APP=run.py
ENV PYTHONPATH=/workspace/backend
ENV PATH="/opt/venv/bin:$PATH"