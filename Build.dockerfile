FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
ENV GNUARMEMB_TOOLCHAIN_PATH="/gnuarmemb"

RUN apt-get -qq update && apt-get install --no-install-recommends -y \
  ccache wget xz-utils file unzip patch \
  gcc-multilib curl ca-certificates \
  build-essential checkinstall

RUN curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 \
  -o gcc-arm-none-eabi.tar.bz2 \
  && tar xvf gcc-arm-none-eabi.tar.bz2 \
  && rm gcc-arm-none-eabi.tar.bz2 \
  && mv gcc-arm-none-eabi-* /opt/gnuarmemb \
  && rm -rf /opt/gnuarmemb/share/doc/gcc-arm-none-eabi/

ENV PATH="/opt/gnuarmemb/bin:${PATH}"

RUN mkdir /sdk && cd /sdk \
  && wget http://mirrors.kernel.org/ubuntu/pool/main/d/device-tree-compiler/device-tree-compiler_1.4.7-1_amd64.deb \
  && wget https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-10-x-x/nRFCommandLineTools1060Linuxamd64tar.gz \
  && tar xvf nRFCommandLineTools1060Linuxamd64tar.gz \
  && dpkg -i nRF-Command-Line-Tools_10_6_0_Linux-amd64.deb device-tree-compiler_1.4.7-1_amd64.deb JLink_Linux_V660e_x86_64.deb \
  && cd / \
  && rm -rf /sdk

WORKDIR /src
