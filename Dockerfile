FROM ubuntu:18.04
ARG download_url

WORKDIR /
RUN apt-get -qq update && apt-get -qq install -y unzip patch curl
RUN curl ${download_url} -o nRF5_SDK.zip && mkdir nrf-sdk && unzip -qq nRF5_SDK.zip -d nrf-sdk && rm nRF5_SDK.zip
