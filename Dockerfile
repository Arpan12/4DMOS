                                                                                              
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# 1. Install system deps and Python 3.10
RUN apt update && apt install -y \
    software-properties-common build-essential cmake ninja-build git curl wget \
    libopenblas-dev libomp-dev \
    python3.10 python3.10-dev python3.10-venv python3.10-distutils

# 2. Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# 3. Patch platform.version globally via PYTHONSTARTUP for all pip/env code
RUN echo 'import platform; platform.version = lambda: "5.15.0"' > /etc/pythonstart.py \
    && echo 'export PYTHONSTARTUP=/etc/pythonstart.py' >> /etc/profile \
    && echo 'PYTHONSTARTUP=/etc/pythonstart.py' >> /etc/environment \
    && export PYTHONSTARTUP=/etc/pythonstart.py

# 4. Install pip and patch environment BEFORE using pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3 && \
    pip install --upgrade pip setuptools wheel packaging && \
    pip install importlib-metadata==6.6.0

# 5. Install PyTorch with CUDA 11.8
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 6. Install ouster-sdk, kiss-icp, and mos4d
RUN pip install ouster-sdk==0.13.1 kiss-icp

# 7. Optional: Clone and install MinkowskiEngine
RUN git clone https://github.com/NVIDIA/MinkowskiEngine.git
WORKDIR /workspace/MinkowskiEngine
