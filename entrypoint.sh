#!/bin/bash

export PATH="/opt/gnuarmemb/bin:${PATH}"
export GNU_INSTALL_ROOT=${GNUARMEMB_TOOLCHAIN_PATH}
export GNU_VERSION=9.2.1
export GNU_PREFIX=arm-none-eabi

cd /nrf-sdk/examples/ble_peripheral/ble_app_blinky/pca10059/s140/
make -j $(nproc)
