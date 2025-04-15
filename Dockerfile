FROM --platform=$BUILDPLATFORM golang:1.23-bookworm AS build-env
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETOS
ARG TARGETARCH

RUN git clone https://github.com/filecoin-project/curio.git /curio \
    && cd /curio && git checkout feat/pdp && cd cmd/pdptool && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build .

FROM ubuntu:24.04
COPY --from=build-env /curio/cmd/pdptool/pdptool /usr/local/bin/pdptool

RUN apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN update-ca-certificates

# Ensure the pdptool binary is executable
RUN /usr/local/bin/pdptool --version

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/pdptool"]
