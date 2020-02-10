#!/bin/bash

export PATH="/opt/gnuarmemb/bin:${PATH}"
export GNU_VERSION=9.2.1
export GNU_PREFIX=arm-none-eabi

cd /src/ble_app
find . -name "Makefile" | xargs dirname | xargs -I _ bash -c "cd _ && pwd && make -j 8"
