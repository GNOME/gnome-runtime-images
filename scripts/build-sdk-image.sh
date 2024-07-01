#! /bin/bash

set -eu

# build the flatpak sdk image
#
# Explicitly specify the repo to install nightly and 44,45 runtimes
# Workaround https://github.com/flathub/flathub/issues/4452
CONTAINER=$(buildah from "${CI_REGISTRY_IMAGE}:base")

export TAG="${CI_REGISTRY_IMAGE}:${ARCH}-gnome-${BRANCH}"
echo "Building $TAG"

if [ "$BRANCH" = "master" ]; then
    buildah run "$CONTAINER" flatpak install gnome-nightly --user --noninteractive \
        "org.gnome.Sdk//${BRANCH}" "org.gnome.Platform//${BRANCH}"
elif [ "$BRANCH" = "44" ] || [ "$BRANCH" = "45" ]; then
    buildah run "$CONTAINER" flatpak install flathub --user --noninteractive \
        "org.gnome.Sdk//${BRANCH}" "org.gnome.Platform//${BRANCH}"
else
    buildah run "$CONTAINER" flatpak install --user --noninteractive \
        "org.gnome.Sdk//${BRANCH}" "org.gnome.Platform//${BRANCH}"
fi

buildah run "$CONTAINER" flatpak install --user --noninteractive \
    "org.freedesktop.Sdk.Extension.rust-stable//${FD_BRANCH}"

buildah run "$CONTAINER" flatpak install --user --noninteractive \
    "org.freedesktop.Sdk//${FD_BRANCH}"

buildah run "$CONTAINER" flatpak install --user --noninteractive \
    "org.freedesktop.Sdk.Extension.llvm${LLVM_VERSION}//${FD_BRANCH}"

buildah run "$CONTAINER" flatpak install --user --noninteractive \
    "org.freedesktop.Sdk.Extension.llvm${LLVM_VERSION_2}//${FD_BRANCH}"

buildah run "$CONTAINER" flatpak install --user --noninteractive \
    "org.freedesktop.Sdk.Extension.vala//${FD_BRANCH}"

buildah run $CONTAINER flatpak install --user --noninteractive \
    "org.freedesktop.Sdk.Extension.vala-nightly//${FD_BRANCH}"

buildah run "$CONTAINER" flatpak info --user "org.gnome.Platform//${BRANCH}"
buildah run "$CONTAINER" flatpak info --user "org.gnome.Sdk//${BRANCH}"

echo "Commiting $TAG"
buildah commit --squash "$CONTAINER" "$TAG"

# push only on master branch
if [ "$CI_COMMIT_REF_NAME" == "master" ]; then
    echo "Pushing $TAG"
    buildah login -u "${OCI_REGISTRY_USER}" -p "${OCI_REGISTRY_PASSWORD}" quay.io
    buildah push "$TAG"
fi
