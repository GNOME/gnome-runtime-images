FROM registry.fedoraproject.org/fedora:latest

VOLUME /build
WORKDIR /build

RUN dnf -y update && \
    dnf install -y flatpak python3-gobject python3-requests python3-aiohttp ostree ostree-libs && \
    dnf clean all

RUN curl -o /usr/bin/flat-manager-client \
    https://raw.githubusercontent.com/flatpak/flat-manager/0.3.4/flat-manager-client && \
    chmod a+x /usr/bin/flat-manager-client
