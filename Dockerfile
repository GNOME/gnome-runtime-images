FROM quay.io/fedora/fedora:39

RUN dnf upgrade -y --best --allowerasing && dnf install -y git 'dnf-command(builddep)' libtool \
        automake gettext-devel autoconf which meson bzip2 && \
    dnf builddep -y flatpak flatpak-builder && \
    dnf groupinstall -y "Development Tools"

RUN git clone --recursive https://github.com/flatpak/flatpak.git && \
    cd flatpak && \
    git checkout 1.14.8 && \
    ./autogen.sh && make -j$(nproc) && make install DESTDIR=/flatpak/destdir

RUN git clone --recursive https://github.com/flatpak/flatpak-builder -b barthalion/run-without-fuse-rebased && \
    cd flatpak-builder && \
    ./autogen.sh --with-system-debugedit && make -j$(nproc)

FROM quay.io/fedora/fedora:39
COPY --from=0 /flatpak/destdir/usr/local /usr/local/
COPY --from=0 /flatpak-builder/flatpak-builder /usr/local/bin/flatpak-builder

RUN useradd --home-dir /build --create-home --shell /bin/bash build
WORKDIR /build

RUN dnf upgrade -y --best --allowerasing && \
    dnf install -y flatpak flatpak-builder librsvg2 ostree fuse elfutils ccache debugedit \
    dconf dbus-daemon dbus-tools git bzr xorg-x11-server-Xvfb dbus-x11 python3-ruamel-yaml \
    python3-gobject python3-pip json-glib jq tracker tracker-miners strace \
    mesa-vulkan-drivers mesa-libEGL mesa-libGL mutter xwayland-run weston && \
    dnf clean all

RUN which bwrap && which flatpak && which flatpak-builder
RUN flatpak --version && flatpak-builder --version && bwrap --version

COPY scripts/install-oras.sh /usr/local/bin/scripts/install-oras.sh
RUN bash /usr/local/bin/scripts/install-oras.sh && rm /usr/local/bin/scripts/install-oras.sh

# generate machine-id as specified in the freedesktop spec:
# https://www.freedesktop.org/software/systemd/man/machine-id.html
# for exmaple, gnome-builder test suite depends on this
RUN dbus-uuidgen > /etc/machine-id

COPY rewrite-flatpak-manifest /usr/local/bin/rewrite-flatpak-manifest

USER build

RUN flatpak remote-add --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
    flatpak remote-add --user gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo && \
    flatpak remote-add --user flathub-beta https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo
