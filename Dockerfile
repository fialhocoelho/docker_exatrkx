# Get a initial image from Nvidia to enable the GPU usage
FROM nvidia/cuda:10.2-devel-ubuntu18.04

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
 && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /app
WORKDIR /app
# send a setup.py copy to docker to install the dependencies
COPY setup.py /app/setup.py
#create a volume to be used as a i/o folder
ENV EXATRKX_DATA=/data
VOLUME /data

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda and Python 3.8
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/home/user/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda install -y python==3.8.3 \
 && conda clean -ya

# Install pytorch
 RUN conda install -y -c pytorch \
     pytorch==1.7.1 \
     torchvision==0.8.2 \
     torchaudio==0.7.2 \
     cudatoolkit=10.2 \
  && conda clean -ya

# Install torch-geometric
RUN pip install torch-scatter -f https://pytorch-geometric.com/whl/torch-1.7.0+cu102.html
RUN pip install torch-sparse -f https://pytorch-geometric.com/whl/torch-1.7.0+cu102.html
RUN pip install torch-cluster -f https://pytorch-geometric.com/whl/torch-1.7.0+cu102.html
RUN pip install torch-spline-conv -f https://pytorch-geometric.com/whl/torch-1.7.0+cu102.html
RUN pip install torch-geometric

# Install pytorch-lightning
RUN pip install  pytorch-lightning==1.2.5

# Install setup
RUN python -m pip install -e .

# Install FAISS
RUN pip install faiss-gpu cupy-cuda102


# Install Pytorch3d
RUN pip install pytorch3d -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py38_cu102_pyt171/download.html

# Set the default command to python3
CMD ["python3"]
