FROM pckzs/nrfsdk-gcc:latest

WORKDIR /
ARG download_url
RUN curl ${download_url} -o nRF5_SDK.zip
RUN bash -c "mkdir nrf-sdk && unzip -qq nRF5_SDK.zip -d nrf-sdk && rm nRF5_SDK.zip;cd /nrf-sdk;shopt -s dotglob;mv nRF5_SDK_*/* .;rmdir nRF5_SDK_*;:;"
