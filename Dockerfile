FROM pytorch/pytorch:1.4-cuda10.1-cudnn7-devel
EXPOSE 20007

RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    cmake \
    unzip \
    build-essential \
    libsm6 \
    libxext6 \
    libfontconfig1 \
    libxrender1 \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavformat-dev \
    libpq-dev \
    libturbojpeg \
    software-properties-common \
    sox \
    libsox-dev \
    libsox-fmt-all \
    bc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install Cython

RUN pip install --no-cache-dir \
    tensorflow-gpu \
    numpy \
    pandas \
    cycler \
    dill \
    h5py \
    imgaug \
    matplotlib \
    seaborn \
    opencv-contrib-python \
    Pillow \
    scikit-image \
    scikit-learn \
    scipy \
    setuptools \
    six \
    tqdm \
    ipython \
    ipdb \
    albumentations \
    click \
    jpeg4py \
    addict \
    mlflow \
    imblearn \
    pycocotools \
    efficientnet_pytorch \
    ipywidgets \
    colorama \
    jupyter \
    PyYAML \
    tensorboard

RUN git clone https://github.com/NVIDIA/apex && \
    cd apex && \
    pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ && \
    cd ..

RUN export LC_ALL=C.UTF-8
RUN export LANG=C.UTF-8
WORKDIR /
