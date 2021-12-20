#!/bin/bash
set -e
set -x

github_username=$(echo $GITHUB_ACTOR|  tr '[:upper:]' '[:lower:]')

dnf -y install dnf-plugins-core
dnf -y copr enable @CoreOS/continuous
dnf -y install git docker skopeo $RPM_OSTREE_VERSION

docker login ghcr.io -u $GITHUB_ACTOR -p $GITHUB_TOKEN

rpm-ostree --version

pushd /tmp/container

git clone -b $SOURCE_REPOSITORY_BRANCH $SOURCE_REPOSITORY source_repository

pushd source_repository

mkdir -p repo cache && ostree --repo=repo init --mode=archive
rpm-ostree compose tree --repo=repo --cachedir=cache $SOURCE_REPOSITORY_MANIFEST
ostree --verbose summary --repo=repo --update

rpm-ostree ex-container encapsulate \
        --repo=repo \
        $BUILD_DESTINATION_OSTREE_REFSPEC \
        docker://ghcr.io/$github_username/$BUILD_DESTINATION_IMAGE_LABEL
