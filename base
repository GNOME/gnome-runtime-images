FROM registry.fedoraproject.org/fedora:latest

RUN dnf upgrade -y --best --allowerasing && dnf install -y git 'dnf-command(builddep)' libtool \
        automake gettext-devel autoconf && \
    dnf builddep -y flatpak-builder && \
    dnf groupinstall -y "Development Tools"

# FIXME: this is a rebased branch cause Bart is on vacation atm.
# RUN git clone --recursive https://github.com/flatpak/flatpak-builder -b run-without-fuse && \
RUN git clone --recursive https://github.com/alatiera/flatpak-builder -b alatiera/run-without-fuse-rebased && \
    cd flatpak-builder && \
    ./autogen.sh --with-system-debugedit && make -j$(nproc)

FROM registry.fedoraproject.org/fedora:latest
COPY --from=0 /flatpak-builder/flatpak-builder /usr/local/bin/flatpak-builder

ENV FLATPAK_GL_DRIVERS=dummy

RUN useradd --home-dir /build --create-home --shell /bin/bash build
WORKDIR /build

RUN dnf upgrade -y --best --allowerasing && \
    dnf install -y flatpak flatpak-builder librsvg2 ostree fuse elfutils ccache debugedit \
    dconf dbus-daemon dbus-tools git bzr xorg-x11-server-Xvfb dbus-x11 python3-ruamel-yaml \
    python3-gobject python3-pip json-glib jq && \
    dnf clean all

# generate machine-id as specified in the freedesktop spec:
# https://www.freedesktop.org/software/systemd/man/machine-id.html
# for exmaple, gnome-builder test suite depends on this
RUN dbus-uuidgen > /etc/machine-id

COPY rewrite-flatpak-manifest /usr/local/bin/rewrite-flatpak-manifest

USER build

RUN flatpak remote-add --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
    flatpak remote-add --user gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo && \
    flatpak remote-add --user flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
