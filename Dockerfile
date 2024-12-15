# Use base image with CUDA and Ubuntu 20.04
FROM nvidia/cuda:12.5.1-cudnn-devel-ubuntu20.04

# Set environment variables for non-interactive installation and timezone
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Paris

# Remove third-party apt sources to avoid issues with expiring keys
# Install basic utilities
RUN rm -f /etc/apt/sources.list.d/*.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    sudo \
    git \
    wget \
    procps \
    git-lfs \
    zip \
    unzip \
    htop \
    vim \
    nano \
    bzip2 \
    libx11-6 \
    build-essential \
    libsndfile-dev \
    software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# Install NVTOP for GPU monitoring
RUN add-apt-repository ppa:flexiondotorg/nvtop && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends nvtop

# Install Node.js and HTTP proxy
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g configurable-http-proxy

# Create a working directory
WORKDIR /app

# Create a non-root user, set up permissions, and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user && \
    chown -R user:user /app && \
    echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user

USER user

# Set home directory and create cache/config directories
ENV HOME=/home/user
RUN mkdir -p $HOME/.cache $HOME/.config && \
    chmod -R 777 $HOME

# Set up Conda environment
ENV CONDA_AUTO_UPDATE_CONDA=false \
    PATH=$HOME/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p ~/miniconda && \
    rm ~/miniconda.sh && \
    conda clean -ya

# Install Python dependencies
RUN conda install -y \
    python=3.9 \
    pip \
    cmake \
    wheel \
    packaging \
    ninja \
    setuptools-scm \
    numpy \
    scipy \
    numba \
    git-lfs \
    torchvision && \
    conda clean -ya

# Install PyTorch nightly version
RUN pip install --upgrade pip && \
    pip install --no-cache-dir --pre torch==2.6.0.dev20241122 --index-url https://download.pytorch.org/whl/nightly/rocm6.2

# Install vllm and huggingface-hub
RUN pip install vllm && \
    pip install huggingface-hub[cli]

# Expose port for the model server
EXPOSE 8007

# Set the working directory to /app and set the model directory
WORKDIR $HOME/app

# Command to run the model server (replace with your specific model path)
CMD ["vllm", "serve", "--device", "cpu", "--port", "7860", "Hjgugugjhuhjggg/mergekit-ties-tzamfyy"]

