#! /bin/bash

set -eux

ORAS_VERSION="1.2.3"
ARCH=$(uname -m)
case "${ARCH}" in \
    x86_64) oras_arch='amd64';; \
    aarch64) oras_arch='arm64';; \
    *) echo >&2 "unsupported architecture: ${ARCH}"; exit 1 ;; \
esac;

curl -LO "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_${oras_arch}.tar.gz" 
mkdir -p oras-install/
tar -zxf oras_${ORAS_VERSION}_*.tar.gz -C oras-install/
mv oras-install/oras oras-install/LICENSE /usr/bin/
rm -rf oras_${ORAS_VERSION}_*.tar.gz oras-install/
