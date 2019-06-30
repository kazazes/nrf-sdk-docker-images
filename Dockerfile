FROM ubuntu:18.04
ARG download_url

WORKDIR /
RUN apt-get update -qq && apt-get install -qq -y unzip patch curl
RUN curl ${download_url} -o nRF5_SDK.zip && mkdir nrf-sdk && unzip -q nRF5_SDK.zip -d nrf-sdk && rm nRF5_SDK.zip
