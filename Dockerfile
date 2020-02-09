FROM pckzs/nrfsdk-gcc:latest

WORKDIR /
ARG download_url
RUN curl ${download_url} -o nRF5_SDK.zip \
  && mkdir -p nrf-sdk && unzip -qq nRF5_SDK.zip -d nrf-sdk \
  && rm nRF5_SDK.zip

COPY entrypoint.sh /entrypoint.sh
COPY Makefile.posix /nrf-sdk/components/toolchain/gcc/Makefile.posix

CMD [ "/entrypoint.sh" ]
