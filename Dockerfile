# FROM python:3.6
FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04
ARG DEBIAN_FRONTEND=noninteractive
RUN rm /etc/apt/sources.list.d/cuda.list

RUN apt-get update
RUN apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget \
    unzip \
    libopenmpi-dev libosmesa6-dev patchelf \
    unrar git \
    nvidia-cuda-toolkit \
    libglfw3 libglfw3-dev \
    software-properties-common

#CUDA/CUDNN
# RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
# RUN mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
# RUN add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
# RUN apt-get update
# RUN apt-get install libcudnn8
# RUN apt-get install libcudnn8-dev
ENV CUDA_VISIBLE_DEVICES=1
WORKDIR /usr/lib/x86_64-linux-gnu
RUN ln -s libcublas.so.10.2.1.243 libcublas.so.11
RUN ln -s libcublasLt.so.10.2.1.243 libcublasLt.so.11
RUN ln -s libcusolver.so.10.2.0.243 libcusolver.so.11
RUN ln -s libcusparse.so.10.3.0.243 libcusparse.so.11
WORKDIR /root


# Install python 3.6
# RUN wget https://www.python.org/ftp/python/3.6.15/Python-3.6.15.tgz
# RUN tar xzf Python-3.6.15.tgz
# WORKDIR ./Python-3.6.15
# RUN ./configure
# RUN make
# RUN make install
# RUN python3.6 -m pip install --upgrade pip
RUN add-apt-repository -y ppa:jblgf0/python
RUN apt-get update
RUN apt-get install -y python3.6 curl
RUN update-alternatives --install /usr/bin/python python3 /usr/bin/python3.6 1
RUN python3.6 --version
RUN curl https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3.6
# RUN pip --version
RUN python3.6 -m pip --version

RUN wget https://www.roboti.us/download/mjpro150_linux.zip && \
    mkdir -p ~/.mujoco && unzip mjpro150_linux.zip -d ~/.mujoco/ && \
    wget https://www.roboti.us/file/mjkey.txt -P ~/.mujoco/ && \
    echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.mujoco/mjpro150/bin" >> ~/.bashrc && \
    echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/nvidia-384" >> ~/.bashrc

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.mujoco/mjpro150/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/nvidia-384
RUN ls ~/.mujoco/

RUN python3.6 -m pip install numpy && \
    python3.6 -m pip install cffi && \
    python3.6 -m pip install Cython && \
    python3.6 -m pip install lockfile
RUN python3.6 -m pip install tensorflow-gpu==1.4.0
RUN python3.6 -m pip install glfw==1.4.0
RUN python3.6 -m pip install imageio==2.1.2
## RUN python3.6 -m pip install fasteners==0.15
# RUN python3.6 -m pip install gym==0.21.0
# RUN python3.6 -m pip install gym==0.16.0
RUN apt-get install -y python3.6-dev libglew-dev
RUN python3.6 -m pip uninstall -y enum34
RUN python3.6 -m pip install baselines
RUN python3.6 -m pip install gym==0.10.0
# RUN python3.6 -m pip install --upgrade pip setuptools wheel
RUN python3.6 -m pip install --verbose opencv-python==4.3.0.38
RUN python3.6 -m pip install psutil
RUN python3.6 -m pip install gym[atari]==0.10.0
RUN python3.6 -m pip uninstall -y tensorflow tensorflow-gpu && python3.6 -m pip install --user tensorflow-gpu==1.4.0
RUN apt -y remove nvidia-*
ENV CUDA_VISIBLE_DEVICES=0

WORKDIR /root/
RUN rm -rf ./ROMS
RUN wget http://www.atarimania.com/roms/Roms.rar
RUN unrar x -o+ ./Roms.rar
RUN python3.6 -m atari_py.import_roms ./ROMS

RUN python3.6 -m pip install matplotlib ipdb
RUN apt-get install -y ffmpeg

COPY . ./random-network-distillation
WORKDIR ./random-network-distillation


CMD [ "python3.6", "run_atari.py", "--num_env", "8", "--gamma_ext", "0.999" ]
