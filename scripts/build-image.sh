#! /bin/bash

set -ex

# For debugging
echo "${DOCKERFILE}" / "${DOCKERIMAGE}"

buildah bud -f "${DOCKERFILE}" -t "${DOCKERIMAGE}" .
# push only on master branch
if [ "$CI_COMMIT_REF_NAME" == master ]; then
    buildah login -u "${OCI_REGISTRY_USER}" -p "${OCI_REGISTRY_PASSWORD}" quay.io
    buildah push "${DOCKERIMAGE}"
fi
