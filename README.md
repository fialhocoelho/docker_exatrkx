# Installing Docker
For installing Docker CE, follow the [official instructions](https://docs.docker.com/engine/install/) for your supported Linux distribution. For convenience, the tutorial below includes instructions on installing Docker for Linux  Ubuntu and Debian distros.

## Setting up Docker
The following steps can be used to setup NVIDIA Container Toolkit on Ubuntu LTS - 16.04, 18.04, 20.4 and Debian - Stretch, Buster distributions.

Docker-CE on Ubuntu can be setup using Docker’s official convenience script:

```
$ curl https://get.docker.com | sh \
  && sudo systemctl --now enable docker
```

## Setting up NVIDIA Container Toolkit
If you want to follow a tutorial for another distro or with more detailed instructions, please follow de [original NVIDIA instructions](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).

Setup the stable repository and the GPG key:

```
$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

Install the nvidia-docker2 package (and dependencies) after updating the package listing:
```
$ sudo apt-get update
$ sudo apt-get install -y nvidia-docker2
```
Restart the Docker daemon to complete the installation after setting the default runtime:
```
$ sudo systemctl restart docker
```
At this point, a working setup can be tested by running a base CUDA container:

```
$ sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```
This should result in a console output shown below:
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 440.33.01    Driver Version: 440.33.01    CUDA Version: 10.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce RTX 2080    Off  | 00000000:83:00.0 Off |                  N/A |
|  0%   55C    P2    28W / 225W |    976MiB /  7982MiB |      6%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0     33562      C   python                                       965MiB |
+-----------------------------------------------------------------------------+
```
This default installation of Docker only allows to run Docker containers as a sudo. If you want to enable Docker runs without privileges, check the following link: [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)


***

# Creating a Docker image to run the ExatrkX pipeline

At the root of this repository, run the following command to create a Docker image from the `Dockerfile` configuration file:
```
$ docker build -t exatrkx-docker-gpu .
```
# Running ExatrkX pipeline example using Docker Container

The volume in this Docker configuration are defined to be used for input and output data.
For exemplification, this tutorial will use the folder `data` in this repository:

At the root of this repository, set the env var `EXATRKX_DATA` to define you folder to I/O:
```
export EXATRKX_DATA=$PWD/data
```

Go to examples folder:
```
cd Pipelines/TrackML_Example/
```
Run the following command to create a Docker container from the image configuration file:
```
sudo docker run --rm -it --init --gpus=all --ipc=host --user="$(id -u):$(id -g)" -v $PWD:/app -v $EXATRKX_DATA:/data exatrkx-docker-gpu traintrack --pipeline_config configs/pipeline_fulldataset.yaml
```
If you want to use other paths to run you pipeline, you need to change the paths in the pipeline configurations files.
E.g.:
```
Pipelines/TrackML_Example/LightningModules/Processing/prepare_dockertest.yaml #configuration file to the Processing step from the pipeline
```

The change the Docker volume configuration, you need to change de `Dockerfile` in the root of this repository.
