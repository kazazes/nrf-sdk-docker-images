ARG NRF_SDK_TAG=16.0.0
ARG DOCKER_HUB=pckzs/nrf-sdk
ARG GCC_ARM_TAR=https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2

FROM ${DOCKER_HUB}:${NRF_SDK_TAG}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && apt-get install --no-install-recommends -y git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc gcc-multilib

RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel && pip3 install --no-cache-dir cmake

RUN curl ${GCC_ARM_TAR} \
  -o gcc-arm-none-eabi.tar.bz2

RUN tar xvf gcc-arm-none-eabi.tar.bz2 && rm gcc-arm-none-eabi.tar.bz2 \
  && mv gcc-arm-none-eabi-* /opt/gcc-arm && rm -rf /opt/gcc-arm/share/doc/gcc-arm-none-eabi/

