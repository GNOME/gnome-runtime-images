#! /bin/bash

set -eux

REGISTRY_TAG="$1"

buildah manifest create "${REGISTRY_TAG}"

buildah manifest add "${REGISTRY_TAG}" "docker://${CI_REGISTRY_IMAGE}:x86_64-${REGISTRY_TAG}"
buildah manifest add "${REGISTRY_TAG}" "docker://${CI_REGISTRY_IMAGE}:aarch64-${REGISTRY_TAG}"

if [ "$CI_COMMIT_REF_NAME" == "master" ]; then
    buildah login -u "${OCI_REGISTRY_USER}" -p "${OCI_REGISTRY_PASSWORD}" quay.io
    buildah manifest push --all "${REGISTRY_TAG}" "docker://${CI_REGISTRY_IMAGE}:${REGISTRY_TAG}"
fi
